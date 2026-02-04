import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<List<Product>> getAllProducts() {
    return _db.getAllProducts();
  }

  // --- IMPLEMENTACIÓN CRUD ---

  @override
  Future<int> createProduct(String name, double price, String category) {
    return _db.into(_db.products).insert(
      ProductsCompanion.insert(
        name: name,
        price: price,
        category: category,
      ),
    );
  }

  @override
  Future<void> updateProduct(Product product) {
    // Usamos 'replace' o 'update' mapeando el modelo de dominio a Companion
    return (_db.update(_db.products)..where((t) => t.id.equals(product.id)))
        .write(ProductsCompanion(
          name: Value(product.name),
          price: Value(product.price),
          category: Value(product.category),
        ));
  }

  @override
  Future<void> deleteProduct(int id) {
    return (_db.delete(_db.products)..where((t) => t.id.equals(id))).go();
  }
}