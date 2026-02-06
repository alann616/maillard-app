import 'package:app/features/pos/domain/models/order_item.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/sales_repository.dart';
import '../database/sales.dart';

/// Implementation of SalesRepository using Drift (SQLite).
class SalesRepositoryImpl implements SalesRepository {
  final AppDatabase _db;

  SalesRepositoryImpl(this._db);

  @override
  Future<List<Sale>> getSalesHistory({DateTime? startDate, DateTime? endDate}) {
    var query = _db.select(_db.sales)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);

    if (startDate != null && endDate != null) {
      query = query..where((t) => t.date.isBetweenValues(startDate, endDate));
    }

    // Filtramos solo las completadas
    // Drift convierte el enum automáticamente, así que comparamos directo con el enum
    query = query..where((t) => t.status.equals(SaleStatus.completed.index));

    return query.get();
  }

  @override
  Stream<List<Sale>> getSalesStream() {
    return (_db.select(_db.sales)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
      ..where((t) => t.status.equals(SaleStatus.completed.index)))
      .watch();
  }

  @override
  Future<List<SaleItem>> getSaleItems(int saleId) {
    return (_db.select(_db.saleItems)..where((t) => t.saleId.equals(saleId))).get();
  }

  @override
  Future<int> registerSale(Sale sale, List<OrderItem> items) async {
    return _db.transaction(() async {
      // 1. Insertar Cabecera (Tabla Sales)
      final saleId = await _db.into(_db.sales).insert(
        SalesCompanion(
          total: Value(sale.total), 
          date: Value(sale.date),
          paymentMethod: Value(sale.paymentMethod),
          // 🔴 CORRECCIÓN AQUÍ: Pasamos el Enum directo, Drift maneja el entero
          status: Value(SaleStatus.completed), 
        ),
      );

      // 2. Insertar Detalles (Tabla SaleItems)
      for (var item in items) {
        await _db.into(_db.saleItems).insert(
          SaleItemsCompanion(
            saleId: Value(saleId),
            productId: Value(item.product.id),
            productName: Value(item.product.name),
            price: Value(item.product.price),
            quantity: Value(item.quantity),
            // total del item calculado automáticamente por Drift si está configurado como generatedAs
          ),
        );
      }
      return saleId;
    });
  }
}