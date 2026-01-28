import 'package:app/core/database/app_database.dart';


abstract class InventoryRepository {
  Stream<List<Ingredient>> getInventoryStream(); // Stream para ver cambios en vivo
}