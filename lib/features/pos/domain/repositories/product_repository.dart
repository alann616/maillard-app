// CORRECCIÓN 3: Importar la DB correcta
import '../../data/database/app_database.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
}