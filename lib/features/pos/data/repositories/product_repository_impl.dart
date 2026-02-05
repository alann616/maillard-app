import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  // ... (Tus métodos existentes: getAllProducts, createProduct, updateProduct, deleteProduct se quedan IGUAL) ...
  @override
  Future<List<Product>> getAllProducts() => _db.getAllProducts(); // O tu implementación actual

  @override
  Future<int> createProduct(String name, double price, String category) {
    // ... tu código actual ...
    return _db
        .into(_db.products)
        .insert(
          ProductsCompanion.insert(
            name: name,
            price: price,
            category: category,
          ),
        );
  }

  @override
  Future<void> updateProduct(Product product) {
    // ... tu código actual ...
    return (_db.update(
      _db.products,
    )..where((t) => t.id.equals(product.id))).write(
      ProductsCompanion(
        name: Value(product.name),
        price: Value(product.price),
        category: Value(product.category),
      ),
    );
  }

  @override
  Future<void> deleteProduct(int id) {
    // ... tu código actual ...
    return (_db.delete(_db.products)..where((t) => t.id.equals(id))).go();
  }

  // --- NUEVA IMPLEMENTACIÓN DE RECETAS ---

  @override
  Future<List<RecipeDTO>> getProductRecipe(int productId) async {
    // Consultamos la tabla 'recipes' filtrando por productId
    final rows = await (_db.select(
      _db.recipes,
    )..where((r) => r.productId.equals(productId))).get();

    // Convertimos los datos de la BD a nuestro objeto simple DTO
    return rows
        .map((r) => RecipeDTO(r.ingredientId, r.quantityRequired))
        .toList();
  }

  @override
  Future<void> updateProductRecipe(int productId, List<RecipeDTO> items) {
    return _db.transaction(() async {
      // 1. Estrategia de Reemplazo: Borramos la receta anterior de este producto
      await (_db.delete(
        _db.recipes,
      )..where((r) => r.productId.equals(productId))).go();

      // 2. Insertamos los nuevos ingredientes uno por uno
      for (var item in items) {
        await _db
            .into(_db.recipes)
            .insert(
              RecipesCompanion.insert(
                productId: productId,
                ingredientId: item.ingredientId,
                quantityRequired: item.quantity,
              ),
            );
      }
    });
  }
}
