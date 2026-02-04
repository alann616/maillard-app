// IMPORT CORREGIDO: Apunta a core/database
import '../../../../core/database/app_database.dart';
import '../../data/database/inventory_transactions.dart';

abstract class InventoryRepository {
  Stream<List<Ingredient>> getInventoryStream();
  Future<void> adjustStock(int ingredientId, double quantity, TransactionType type); // <--- NUEVO
}