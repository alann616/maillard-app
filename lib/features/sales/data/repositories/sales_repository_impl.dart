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
    // Start building the query on the Sales table
    var query = _db.select(_db.sales)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);

    // Apply date range filter if provided
    if (startDate != null && endDate != null) {
      query = query..where((t) => t.date.isBetweenValues(startDate, endDate));
    }

    // Filter only COMPLETED sales (ignore pending/open tables)
    // We access the enum index as stored in the database
    query = query..where((t) => t.status.equals(SaleStatus.completed.index));

    return query.get();
  }

  @override
  Future<List<SaleItem>> getSaleItems(int saleId) {
    // Retrieve all items associated with a specific sale ID
    return (_db.select(_db.saleItems)..where((t) => t.saleId.equals(saleId))).get();
  }
}