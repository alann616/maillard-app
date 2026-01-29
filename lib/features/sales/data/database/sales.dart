import 'package:drift/drift.dart';

// Enum para el estado de la venta
enum SaleStatus {
  pending, // Cuenta abierta (Mesa ocupada)
  completed, // Cobrada (Mesa libre)
  cancelled, // Cancelada
}

// 1. La Cabecera de la Venta (El Ticket general)
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get total => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get paymentMethod => text()(); // 'Efectivo', 'Tarjeta', etc.

  IntColumn get tableId => integer().nullable()();
  IntColumn get status =>
      intEnum<SaleStatus>().withDefault(const Constant(0))();
}

// 2. Los Items de la Venta (El detalle)
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get price => real()();
  IntColumn get quantity => integer()();
  RealColumn get total => real().generatedAs(price * quantity.cast<double>())();
}
