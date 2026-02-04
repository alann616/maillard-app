import 'package:drift/drift.dart';
import 'inventory.dart'; // Importamos para referenciar a la clase Ingredients

enum TransactionType {
  purchase,   // Compra (Entrada)
  sale,       // Venta (Salida automática)
  adjustment, // Ajuste manual (Merma, robo, regalo)
  initial     // Stock inicial
}

class InventoryTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Referencia a la tabla Ingredients (que ya existe en tu DB)
  IntColumn get ingredientId => integer().references(Ingredients, #id)();
  
  // Cantidad movida (Positivo o Negativo)
  RealColumn get quantity => real()();
  
  // Tipo de movimiento (mapeado como índice del Enum: 0, 1, 2, 3)
  IntColumn get type => integer().map(const EnumIndexConverter<TransactionType>(TransactionType.values))();
  
  // Fecha del movimiento
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
}