// IMPORT CORREGIDO: Apunta a core/database
import '../../../../core/database/app_database.dart';

abstract class InventoryRepository {
  Stream<List<Ingredient>> getInventoryStream();
  Future<void> addStock(int ingredientId, double quantity); // <--- NUEVO
}