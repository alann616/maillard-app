import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/sales_repository.dart';

// --- EVENTOS ---
abstract class SalesEvent extends Equatable {
  const SalesEvent();
  @override
  List<Object> get props => [];
}

class LoadSalesHistory extends SalesEvent {}

// --- ESTADOS ---
abstract class SalesState extends Equatable {
  const SalesState();
  @override
  List<Object> get props => [];
}

class SalesInitial extends SalesState {}
class SalesLoading extends SalesState {}
class SalesLoaded extends SalesState {
  final List<Sale> sales;
  final double totalRevenue; // Agregamos el total sumado para facilitar la UI

  const SalesLoaded({required this.sales, required this.totalRevenue});
  
  @override
  List<Object> get props => [sales, totalRevenue];
}
class SalesError extends SalesState {
  final String message;
  const SalesError(this.message);
}

// --- BLOC ---
class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository _repository;

  SalesBloc(this._repository) : super(SalesInitial()) {
    on<LoadSalesHistory>((event, emit) async {
      emit(SalesLoading());
      try {
        // Por ahora traemos todo el historial histórico
        // Luego agregaremos filtros de "Hoy", "Semana", etc.
        final sales = await _repository.getSalesHistory();
        
        // Calculamos el total vendido
        final total = sales.fold(0.0, (sum, sale) => sum + sale.total);

        emit(SalesLoaded(sales: sales, totalRevenue: total));
      } catch (e) {
        emit(SalesError("Error cargando ventas: $e"));
      }
    });
  }
}