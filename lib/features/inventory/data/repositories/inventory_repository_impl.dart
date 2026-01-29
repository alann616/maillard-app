// IMPORT CORREGIDO: Apunta a core/database
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;
  InventoryRepositoryImpl(this._db);

  @override
  Stream<List<Ingredient>> getInventoryStream() {
    return _db.select(_db.ingredients).watch();
  }

  // --- IMPLEMENTACIÓN NUEVA ---
  @override
  Future<void> addStock(int ingredientId, double quantity) async {
    await _db.addStock(ingredientId, quantity);
  }
}