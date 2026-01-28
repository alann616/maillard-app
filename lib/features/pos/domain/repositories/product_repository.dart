// CORRECCIÓN 3: Importar la DB correcta
import '../../../../core/database/app_database.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
}