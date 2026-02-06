import 'package:drift/drift.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:app/features/inventory/data/database/inventory_transactions.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;

  InventoryRepositoryImpl(this._db);

  @override
  Stream<List<Ingredient>> getInventoryStream() {
    return _db.select(_db.ingredients).watch();
  }

  @override
  Future<void> adjustStock(int ingredientId, double quantity, TransactionType type) {
    return _db.transaction(() async {
      
      await _db.into(_db.inventoryTransactions).insert(
        InventoryTransactionsCompanion.insert(
          ingredientId: ingredientId,
          quantity: quantity,
          type: type,
          date: Value(DateTime.now()),
        ),
      );

      final currentItem = await (_db.select(_db.ingredients)
        ..where((t) => t.id.equals(ingredientId)))
        .getSingle();
      
      final newStock = currentItem.currentStock + quantity;

      await (_db.update(_db.ingredients)
        ..where((t) => t.id.equals(ingredientId)))
        .write(
          IngredientsCompanion(
            currentStock: Value(newStock),
          )
      );
      
      // Debug (Opcional): Para ver en consola que todo salió bien
      print("📦 Stock actualizado: ${currentItem.name} -> $newStock (Mov: $quantity)");
    });
  }

  @override
  Future<int> createIngredient(String name, String unit, double cost, double minStock, double initialStock) {
    return _db.transaction(() async {
      // 1. Crear el ingrediente (Usamos Value() explícito para evitar ambigüedades de tipo)
      final id = await _db.into(_db.ingredients).insert(
        IngredientsCompanion(
          name: Value(name),
          unit: Value(unit),
          costPerUnit: Value(cost),
          minStock: Value(minStock),
          currentStock: Value(initialStock),
        ),
      );

      // 2. Si hay stock inicial, registramos el ajuste en el historial
      if (initialStock > 0) {
        await _db.into(_db.inventoryTransactions).insert(
          InventoryTransactionsCompanion(
            ingredientId: Value(id),
            quantity: Value(initialStock),
            type: const Value(TransactionType.adjustment),
            date: Value(DateTime.now()),
          ),
        );
      }
      return id;
    });
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) {
    // Solo actualizamos metadatos, NO el stock (eso se hace vía adjustStock)
    return (_db.update(_db.ingredients)..where((t) => t.id.equals(ingredient.id)))
        .write(IngredientsCompanion(
          name: Value(ingredient.name),
          unit: Value(ingredient.unit),
          costPerUnit: Value(ingredient.costPerUnit),
          minStock: Value(ingredient.minStock),
        ));
  }

  @override
  Future<void> deleteIngredient(int id) {
    return (_db.delete(_db.ingredients)..where((t) => t.id.equals(id))).go();
  }
}