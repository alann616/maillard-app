import '../../../../core/database/app_database.dart';

// DTO simple para transportar datos de receta (Ingrediente + Cantidad)
class RecipeDTO {
  final int ingredientId;
  final double quantity;
  RecipeDTO(this.ingredientId, this.quantity);
}

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<int> createProduct(String name, double price, String category);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);

  // --- NUEVOS MÉTODOS PARA RECETAS ---
  /// Obtiene la lista de ingredientes (ID y cantidad) configurados para un producto
  Future<List<RecipeDTO>> getProductRecipe(int productId);
  
  /// Guarda la receta completa (borra la configuración anterior y pone la nueva)
  Future<void> updateProductRecipe(int productId, List<RecipeDTO> items);
}