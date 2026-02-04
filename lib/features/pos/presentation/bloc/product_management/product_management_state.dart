part of 'product_management_bloc.dart';

sealed class ProductManagementState extends Equatable {
  const ProductManagementState();
  @override
  List<Object> get props => [];
}

final class ProductManagementInitial extends ProductManagementState {}
final class ProductManagementLoading extends ProductManagementState {}

final class ProductManagementLoaded extends ProductManagementState {
  final List<Product> products;
  // Timestamp para forzar redibujado si la lista es igual pero cambió el contenido
  final int timestamp; 

  const ProductManagementLoaded(this.products, this.timestamp);
  
  @override
  List<Object> get props => [products, timestamp];
}

final class ProductManagementError extends ProductManagementState {
  final String message;
  const ProductManagementError(this.message);
}

// Estado especial para indicar éxito en una operación (y cerrar diálogos, por ejemplo)
final class ProductOperationSuccess extends ProductManagementState {
  final String message;
  const ProductOperationSuccess(this.message);
}