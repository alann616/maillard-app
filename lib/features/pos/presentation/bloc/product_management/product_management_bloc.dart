import 'package:app/core/database/app_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/product_repository.dart';

part 'product_management_event.dart';
part 'product_management_state.dart';

class ProductManagementBloc
    extends Bloc<ProductManagementEvent, ProductManagementState> {
  final ProductRepository _repository;

  ProductManagementBloc(this._repository)
    : super(ProductManagementInitial()) {

    on<LoadAdminProducts>((event, emit) async {
      emit(ProductManagementLoading());
      try {
        final products = await _repository.getAllProducts();
        emit(
          ProductManagementLoaded(
            products,
            DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } catch (e) {
        emit(ProductManagementError("Error cargando productos: $e"));
      }
    });

    on<CreateProductEvent>((event, emit) async {
      emit(ProductManagementLoading());
      try {
        await _repository.createProduct(
          event.name,
          event.price,
          event.category,
        );
        emit(const ProductOperationSuccess("Producto creado exitosamente"));
        add(LoadAdminProducts()); // Recargar lista
      } catch (e) {
        emit(ProductManagementError("Error al crear: $e"));
      }
    });

    on<UpdateProductEvent>((event, emit) async {
      emit(ProductManagementLoading());
      try {
        await _repository.updateProduct(event.product);
        emit(const ProductOperationSuccess("Producto actualizado"));
        add(LoadAdminProducts());
      } catch (e) {
        emit(ProductManagementError("Error al actualizar: $e"));
      }
    });

    on<DeleteProductEvent>((event, emit) async {
      emit(ProductManagementLoading());
      try {
        await _repository.deleteProduct(event.id);
        emit(const ProductOperationSuccess("Producto eliminado"));
        add(LoadAdminProducts());
      } catch (e) {
        emit(ProductManagementError("Error al eliminar: $e"));
      }
    });
  }
}
