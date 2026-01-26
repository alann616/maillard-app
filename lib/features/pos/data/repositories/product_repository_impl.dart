import '../../domain/repositories/product_repository.dart';
import '../database/app_database.dart'; // <--- Ruta correcta a la BD

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;
  ProductRepositoryImpl(this._db);

  @override
  Future<List<Product>> getAllProducts() => _db.getAllProducts();
}