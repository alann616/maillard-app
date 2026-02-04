import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/inventory_repository.dart';
// Importamos el archivo donde definiste el Enum y la Tabla nueva
import '../database/inventory_transactions.dart'; 

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;

  InventoryRepositoryImpl(this._db);

  @override
  Stream<List<Ingredient>> getInventoryStream() {
    // Escucha cambios en tiempo real de la tabla de ingredientes
    return _db.select(_db.ingredients).watch();
  }

  @override
  Future<void> adjustStock(int ingredientId, double quantity, TransactionType type) {
    // 🛡️ TRANSACCIÓN ATÓMICA (ACID)
    // Esto asegura que se guarden AMBOS cambios (Log y Stock) o NINGUNO.
    return _db.transaction(() async {
      
      // PASO 1: Registrar el movimiento en el Historial (Audit Log)
      // Usamos InventoryTransactionsCompanion para insertar de forma segura
      await _db.into(_db.inventoryTransactions).insert(
        InventoryTransactionsCompanion.insert(
          ingredientId: ingredientId,
          quantity: quantity,
          type: type,
          date: Value(DateTime.now()),
        ),
      );

      // PASO 2: Calcular el nuevo stock
      // Primero leemos el valor actual de la base de datos (lectura fresca)
      final currentItem = await (_db.select(_db.ingredients)
        ..where((t) => t.id.equals(ingredientId)))
        .getSingle();
      
      final newStock = currentItem.currentStock + quantity;

      // PASO 3: Actualizar la tabla maestra de ingredientes
      await (_db.update(_db.ingredients)
        ..where((t) => t.id.equals(ingredientId)))
        .write(
          IngredientsCompanion(
            currentStock: Value(newStock),
          ),
      );
      
      // Debug (Opcional): Para ver en consola que todo salió bien
      // print("📦 Stock actualizado: ${currentItem.name} -> $newStock (Mov: $quantity)");
    });
  }
}