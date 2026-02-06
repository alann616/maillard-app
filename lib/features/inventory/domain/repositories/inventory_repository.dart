import 'package:app/core/database/app_database.dart';
import 'package:app/features/inventory/data/database/inventory_transactions.dart';

abstract class InventoryRepository {
  Stream<List<Ingredient>> getInventoryStream();
  
  // Create sí devuelve int (el ID creado), eso es útil.
  Future<int> createIngredient({
    required String name,
    required String unit,
    required double cost,
    required double minStock,
    double initialStock = 0.0, // Opcional con default
    String? purchaseUnit,      // Opcional
    double? packageSize,       // Opcional
  });

  Future<void> updateIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(int id);
  
  Future<void> adjustStock(int ingredientId, double quantity, TransactionType type);
}