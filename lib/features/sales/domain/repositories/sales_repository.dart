import 'package:app/features/pos/domain/models/order_item.dart';

import '../../../../core/database/app_database.dart';

abstract class SalesRepository {
  /// Historial de ventas (filtro opcional por fechas)
  Future<List<Sale>> getSalesHistory({DateTime? startDate, DateTime? endDate});
  
  /// Escucha en tiempo real (Stream) para actualizar reportes automáticamente
  Stream<List<Sale>> getSalesStream();

  /// Detalles de una venta
  Future<List<SaleItem>> getSaleItems(int saleId);

  /// Registrar una venta nueva (Cabecera + Detalles)
  Future<int> registerSale(Sale sale, List<OrderItem> items);
}