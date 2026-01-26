import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// CORRECCIONES DE RUTAS:
import '../../data/database/app_database.dart';
import '../../domain/models/order_item.dart';
import '../../domain/repositories/product_repository.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
    // ... (El resto del código dentro de la clase está bien, solo eran los imports)
    final ProductRepository _repository;

  MenuBloc(this._repository) : super(const MenuState()) {
    on<LoadProducts>((event, emit) async {
      emit(state.copyWith(status: MenuStatus.loading));
      try {
        final products = await _repository.getAllProducts();
        emit(state.copyWith(status: MenuStatus.success, products: products));
      } catch (e) {
        emit(state.copyWith(status: MenuStatus.failure, errorMessage: e.toString()));
      }
    });

    on<AddProductToOrder>((event, emit) {
      final items = List<OrderItem>.from(state.orderItems);
      final index = items.indexWhere((i) => i.product.id == event.product.id);
      if (index != -1) {
        items[index] = items[index].increment();
      } else {
        items.add(OrderItem(product: event.product, quantity: 1));
      }
      emit(state.copyWith(orderItems: items));
    });

    on<RemoveProductFromOrder>((event, emit) {
      final items = List<OrderItem>.from(state.orderItems);
      final index = items.indexWhere((i) => i.product.id == event.product.id);
      if (index == -1) return;
      
      if (items[index].quantity > 1) {
        items[index] = items[index].decrement();
      } else {
        items.removeAt(index);
      }
      emit(state.copyWith(orderItems: items));
    });

    on<ProcessCheckout>((event, emit) {
      print("💰 Venta guardada: \$${state.total}");
      emit(state.copyWith(orderItems: []));
    });
  }
}