import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// Para usar debugPrint y quitar los warnings amarillos
import 'package:flutter/foundation.dart'; 

// --- IMPORTS DE DOMINIO Y TABLAS ---
import '../../features/pos/domain/models/product.dart';
import '../../features/auth/data/database/users.dart';
import '../../features/pos/domain/models/user_role.dart';
import '../../features/sales/data/database/sales.dart';
import '../../features/inventory/data/database/inventory.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Products, Users, Sales, SaleItems, Ingredients, Recipes],
)
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  // --- MIGRACIÓN ---
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
      },
    );
  }

  // --- QUERIES ---
  Future<List<Product>> getAllProducts() => select(products).get();

  Future<User?> getUserByPin(String pin) {
    return (select(users)..where((t) => t.pin.equals(pin))).getSingleOrNull();
  }

  // --- TRANSACCIÓN DE VENTA + DESCUENTO DE INVENTARIO ---
  Future<void> createSale({
    required double total,
    required String paymentMethod,
    required List<SaleItemsCompanion> items,
  }) {
    return transaction(() async {
      // 1. Guardar la Venta
      final saleId = await into(sales).insert(
        SalesCompanion.insert(
          total: total,
          paymentMethod: paymentMethod,
          date: Value(DateTime.now()),
        ),
      );

      // 2. Guardar items y procesar inventario
      for (var item in items) {
        // A. Guardar item de venta
        await into(saleItems).insert(item.copyWith(saleId: Value(saleId)));

        // B. Buscar la Receta
        final productId = item.productId.value;
        final soldQuantity = item.quantity.value;

        // Traemos todos los ingredientes que usa este producto
        final productRecipe = await (select(recipes)
              ..where((r) => r.productId.equals(productId)))
            .get();

        // C. Descontar cada ingrediente
        for (var component in productRecipe) {
          final totalDeduct = component.quantityRequired * soldQuantity;

          // --- AQUÍ ESTABA EL ERROR ---
          // Usamos 'ingredients.currentStock' para referirnos a la columna
          await (update(ingredients)
                ..where((i) => i.id.equals(component.ingredientId)))
              .write(
            IngredientsCompanion.custom(
              currentStock: ingredients.currentStock - Constant(totalDeduct),
            ),
          );

          debugPrint(
            "🔻 Descontados $totalDeduct de ingrediente ID ${component.ingredientId}",
          );
        }
      }
      debugPrint("✅ Venta $saleId registrada y stock actualizado.");
    });
  }

  // --- SEED (Datos Iniciales) ---
  Future<void> seedInitialData() async {
    // 1. Productos
    if (await select(products).get().then((l) => l.isEmpty)) {
      await batch((batch) {
        batch.insertAll(products, [
          ProductsCompanion.insert(name: 'Espresso Doble', price: 45.0, category: 'Bebida'), // ID 1
          ProductsCompanion.insert(name: 'Latte 10oz', price: 65.0, category: 'Bebida'),     // ID 2
        ]);
      });
    }
    // 2. Usuarios
    if (await select(users).get().then((l) => l.isEmpty)) {
      await into(users).insert(UsersCompanion.insert(name: 'Admin', pin: '1234', role: UserRole.admin));
    }
    // 3. INGREDIENTES
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
    // 4. RECETAS
    if (await select(recipes).get().then((l) => l.isEmpty)) {
      await batch((batch) {
        batch.insertAll(recipes, [
          // Espresso: 18g Café
          RecipesCompanion.insert(productId: 1, ingredientId: 1, quantityRequired: 18.0),
          // Latte: 18g Café + 250ml Leche + 1 Vaso
          RecipesCompanion.insert(productId: 2, ingredientId: 1, quantityRequired: 18.0),
          RecipesCompanion.insert(productId: 2, ingredientId: 2, quantityRequired: 250.0),
          RecipesCompanion.insert(productId: 2, ingredientId: 3, quantityRequired: 1.0),
        ]);
      });
      debugPrint("🌱 SQLite: Recetas configuradas.");
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'maillard.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}