import 'package:drift/drift.dart';

// 1. La Cabecera de la Venta (El Ticket general)
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get total => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get paymentMethod => text()(); // 'Efectivo', 'Tarjeta', etc.
}

// 2. Los Items de la Venta (El detalle)
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Relación con la tabla Sales
  IntColumn get saleId => integer().references(Sales, #id)();
  
  // Datos del producto snapshot
  IntColumn get productId => integer()(); 
  TextColumn get productName => text()(); 
  RealColumn get price => real()();       
  IntColumn get quantity => integer()();
  
  // CORRECCIÓN AQUÍ:
  // Quitamos 'fromDart'. Multiplicamos las columnas directo.
  // Usamos .cast<double>() en quantity para asegurar que multiplicamos peras con peras (Real * Real)
  RealColumn get total => real().generatedAs(price * quantity.cast<double>())();
}