import '../../../../core/database/app_database.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();

  Future<int> createProduct(String name, double price, String category);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}