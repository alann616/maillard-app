import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

// --- IMPORTS DE DOMINIO Y TABLAS ---
import '../../features/pos/domain/models/product.dart';
import '../../features/auth/data/database/users.dart';
import '../../features/pos/domain/models/user_role.dart';
import '../../features/sales/data/database/sales.dart';
import '../../features/inventory/data/database/inventory.dart';
import '../../features/pos/data/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products, Users, Sales, SaleItems, Ingredients, Recipes, RestaurantTables],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  // --- ESTRATEGIA DE MIGRACIÓN ---
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) await m.createTable(users);
        if (from < 3) {
          await m.createTable(sales);
          await m.createTable(saleItems);
        }
        if (from < 4) {
          await m.createTable(ingredients);
          await m.createTable(recipes);
        }
        if (from < 5) {
          await m.createTable(restaurantTables);
          await m.addColumn(sales, sales.status);
          await m.addColumn(sales, sales.tableId);
        }
      },
    );
  }

  // --- QUERIES BÁSICAS ---
  Future<List<Product>> getAllProducts() => select(products).get();

  Future<User?> getUserByPin(String pin) {
    return (select(users)..where((t) => t.pin.equals(pin))).getSingleOrNull();
  }

  // --- QUERIES DE INVENTARIO ---
  Stream<List<Ingredient>> getInventoryStream() => select(ingredients).watch();

  Future<void> addStock(int ingredientId, double quantity) {
    return (update(ingredients)..where((i) => i.id.equals(ingredientId))).write(
      IngredientsCompanion.custom(
        currentStock: ingredients.currentStock + Constant(quantity),
      ),
    );
  }

  // --- QUERIES DE MESAS (Live Tables) ---
  
  /// Observa las mesas y une con ventas pendientes para determinar estado (Libre/Ocupada)
  Stream<List<TableWithStatus>> watchTables() {
    final query = select(restaurantTables).join([
      leftOuterJoin(
        sales, 
        sales.tableId.equalsExp(restaurantTables.id) & 
        sales.status.equals(SaleStatus.pending.index)
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final table = row.readTable(restaurantTables);
        final sale = row.readTableOrNull(sales);
        return TableWithStatus(table: table, activeSale: sale);
      }).toList();
    });
  }

  Future<void> seedTables() async {
    if (await select(restaurantTables).get().then((l) => l.isEmpty)) {
      await batch((batch) {
        batch.insertAll(restaurantTables, [
          for (var i = 1; i <= 6; i++) RestaurantTablesCompanion.insert(name: 'Mesa $i'),
          RestaurantTablesCompanion.insert(name: 'Barra 1'),
          RestaurantTablesCompanion.insert(name: 'Barra 2'),
        ]);
      });
      debugPrint("🌱 SQLite: Mesas sembradas.");
    }
  }

  // ===========================================================================
  // === LÓGICA DE COMANDAS PERSISTENTES (CEREBRO DEL POS) ===
  // ===========================================================================

  /// 1. RECUPERAR: Busca si hay una cuenta abierta en la mesa para recargarla en pantalla.
  Future<PendingSaleData?> getPendingOrder(int tableId) async {
    final sale = await (select(sales)
      ..where((s) => s.tableId.equals(tableId) & s.status.equals(SaleStatus.pending.index)))
      .getSingleOrNull();
    
    if (sale == null) return null;

    final items = await (select(saleItems)..where((i) => i.saleId.equals(sale.id))).get();
    
    return PendingSaleData(sale: sale, items: items);
  }

  /// 2. GUARDAR (Enviar a Cocina): Crea o Actualiza una venta PENDIENTE.
  /// NO descuenta inventario todavía (eso es al cobrar).
  Future<void> savePendingOrder({
    required int tableId,
    required double total,
    required List<SaleItemsCompanion> items,
  }) {
    return transaction(() async {
      // Verificar si ya existe una cuenta abierta
      final existingSale = await (select(sales)
        ..where((s) => s.tableId.equals(tableId) & s.status.equals(SaleStatus.pending.index)))
        .getSingleOrNull();

      int saleId;
      
      if (existingSale != null) {
        // A. ACTUALIZAR: Mantenemos el ID, actualizamos total y fecha
        saleId = existingSale.id;
        await (update(sales)..where((s) => s.id.equals(saleId))).write(
          SalesCompanion(total: Value(total), date: Value(DateTime.now()))
        );
        // Borramos items viejos y ponemos los nuevos (Estrategia de reemplazo total para evitar conflictos)
        await (delete(saleItems)..where((i) => i.saleId.equals(saleId))).go();
      } else {
        // B. CREAR: Nueva venta con status PENDIENTE
        saleId = await into(sales).insert(SalesCompanion.insert(
          total: total,
          paymentMethod: 'Pendiente',
          date: Value(DateTime.now()),
          tableId: Value(tableId),
          status: Value(SaleStatus.pending), // <--- Esto activará el color ROJO en mesas
        ));
      }

      // Insertar los items actuales de la orden
      for (var item in items) {
        await into(saleItems).insert(item.copyWith(saleId: Value(saleId)));
      }
      debugPrint("📝 Comanda guardada/actualizada para Mesa $tableId (ID Venta: $saleId)");
    });
  }

  /// 3. COBRAR (Finalizar): Cierra la cuenta pendiente (o crea una rápida) y DESCUENTA inventario.
/// 3. COBRAR (Finalizar): Cierra la cuenta pendiente (o crea una rápida) y DESCUENTA inventario.
  Future<void> completeSale({
    required int? tableId,
    required double total,
    required List<SaleItemsCompanion> items,
  }) {
    return transaction(() async {
      int finalSaleId;

      // Variable para guardar la venta encontrada (si existe)
      Sale? existingSale;

      // CORRECCIÓN: Solo buscamos venta pendiente si hay una mesa (tableId no es null)
      if (tableId != null) {
        existingSale = await (select(sales)
          ..where((s) => s.tableId.equals(tableId) & s.status.equals(SaleStatus.pending.index)))
          .getSingleOrNull();
      }

      if (existingSale != null) {
        // A. CERRAR PENDIENTE: Cambiamos estado a COMPLETED
        finalSaleId = existingSale.id;
        await (update(sales)..where((s) => s.id.equals(finalSaleId))).write(
          SalesCompanion(
            status: Value(SaleStatus.completed), // <--- Cierra la mesa (VERDE)
            total: Value(total),
            paymentMethod: const Value('Efectivo'),
            date: Value(DateTime.now()),
          )
        );
        // Reemplazamos items
        await (delete(saleItems)..where((i) => i.saleId.equals(finalSaleId))).go();
      } else {
        // B. VENTA RÁPIDA (o mesa sin comanda previa): Creamos venta nueva cerrada
        finalSaleId = await into(sales).insert(
          SalesCompanion.insert(
            total: total,
            paymentMethod: 'Efectivo',
            date: Value(DateTime.now()),
            tableId: Value(tableId),
            status: Value(SaleStatus.completed),
          ),
        );
      }

      // Guardar Items Finales y PROCESAR INVENTARIO
      for (var item in items) {
        await into(saleItems).insert(item.copyWith(saleId: Value(finalSaleId)));
        
        // --- LÓGICA DE INVENTARIO (RECETAS) ---
        final productId = item.productId.value;
        final soldQuantity = item.quantity.value;

        // Buscamos receta
        final productRecipe = await (select(recipes)..where((r) => r.productId.equals(productId))).get();
        
        // Descontamos ingredientes
        for (var component in productRecipe) {
          final totalDeduct = component.quantityRequired * soldQuantity;
          await (update(ingredients)..where((i) => i.id.equals(component.ingredientId))).write(
            IngredientsCompanion.custom(currentStock: ingredients.currentStock - Constant(totalDeduct)),
          );
          debugPrint("🔻 Descontados $totalDeduct de ingrediente ID ${component.ingredientId}");
        }
      }
      debugPrint("✅ Venta $finalSaleId FINALIZADA para Mesa ${tableId ?? 'Rápida'}");
    });
  }

  // --- SEED GLOBAL ---
  Future<void> seedInitialData() async {
    // 1. Productos
    if (await select(products).get().then((l) => l.isEmpty)) {
      await batch((batch) {
        batch.insertAll(products, [
          ProductsCompanion.insert(name: 'Espresso Doble', price: 45.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'Latte 10oz', price: 65.0, category: 'Bebida'),
        ]);
      });
    }
    // 2. Usuarios
    if (await select(users).get().then((l) => l.isEmpty)) {
      await into(users).insert(UsersCompanion.insert(name: 'Admin', pin: '1234', role: UserRole.admin));
    }
    // 3. Inventario
    if (await select(ingredients).get().then((l) => l.isEmpty)) {
      await batch((batch) {
        batch.insertAll(ingredients, [
          IngredientsCompanion.insert(name: 'Café Grano', unit: 'g', currentStock: 1000.0, costPerUnit: 0.5),
          IngredientsCompanion.insert(name: 'Leche Entera', unit: 'ml', currentStock: 5000.0, costPerUnit: 0.02),
          IngredientsCompanion.insert(name: 'Vaso 10oz', unit: 'pz', currentStock: 100.0, costPerUnit: 2.0),
        ]);
      });
      debugPrint("🌱 SQLite: Insumos sembrados.");
    }
    // 4. Recetas
    if (await select(recipes).get().then((l) => l.isEmpty)) {
      await batch((batch) {
        batch.insertAll(recipes, [
          RecipesCompanion.insert(productId: 1, ingredientId: 1, quantityRequired: 18.0),
          RecipesCompanion.insert(productId: 2, ingredientId: 1, quantityRequired: 18.0),
          RecipesCompanion.insert(productId: 2, ingredientId: 2, quantityRequired: 250.0),
          RecipesCompanion.insert(productId: 2, ingredientId: 3, quantityRequired: 1.0),
        ]);
      });
      debugPrint("🌱 SQLite: Recetas configuradas.");
    }
    // 5. Mesas
    await seedTables();
  }
}

/// DTO para devolver una venta completa (Cabecera + Items)
class PendingSaleData {
  final Sale sale;
  final List<SaleItem> items;
  PendingSaleData({required this.sale, required this.items});
}

/// Helper para Grid de Mesas
class TableWithStatus {
  final RestaurantTable table;
  final Sale? activeSale; // Null si la mesa está libre

  TableWithStatus({required this.table, this.activeSale});
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'maillard.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}