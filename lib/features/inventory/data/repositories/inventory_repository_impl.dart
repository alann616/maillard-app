import '../../../../core/database/app_database.dart';
import '../../data/database/inventory.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;
  InventoryRepositoryImpl(this._db);

  @override
  Stream<List<Ingredient>> getInventoryStream() {
    // select(ingredients).watch() devuelve un Stream que se actualiza
    // AUTOMÁTICAMENTE cada vez que haces una venta. ¡Magia de Drift!
    return _db.select(_db.ingredients).watch();
  }
}