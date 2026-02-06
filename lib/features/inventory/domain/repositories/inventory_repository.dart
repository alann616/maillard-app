import 'package:app/core/database/app_database.dart'; 
import 'package:app/features/inventory/data/database/inventory_transactions.dart';

abstract class InventoryRepository {
  /// Escucha cambios en tiempo real del inventario
  Stream<List<Ingredient>> getInventoryStream();

  /// Ajusta el stock (Suma o Resta) y genera un log en el historial
  Future<void> adjustStock(int ingredientId, double quantity, TransactionType type);

  // --- NUEVOS MÉTODOS CRUD ---

  /// Crea un nuevo insumo y registra su stock inicial
  Future<int> createIngredient(String name, String unit, double cost, double minStock, double initialStock);

  /// Actualiza datos básicos (Nombre, Unidad, Costo, Mínimo). NO altera el stock actual.
  Future<void> updateIngredient(Ingredient ingredient);

  /// Elimina un insumo de la base de datos
  Future<void> deleteIngredient(int id);
}