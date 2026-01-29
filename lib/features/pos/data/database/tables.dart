import 'package:drift/drift.dart';

class RestaurantTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // "Mesa 1", "Barra 2"
  // No guardamos el estado "Ocupado" aquí.
  // El estado se calcula: ¿Existe una venta con status 'pending' para esta mesa?
}