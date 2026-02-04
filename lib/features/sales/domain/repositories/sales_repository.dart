import '../../../../core/database/app_database.dart';

abstract class SalesRepository {
  /// Obtiene el historial de ventas completo.
  /// Opcionalmente filtra por fecha (lo usaremos para el corte del día).
  Future<List<Sale>> getSalesHistory({DateTime? startDate, DateTime? endDate});
  
  /// Obtiene los detalles (items) de una venta específica.
  Future<List<SaleItem>> getSaleItems(int saleId);
}