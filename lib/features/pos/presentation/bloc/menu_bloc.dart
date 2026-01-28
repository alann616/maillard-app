import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:flutter/foundation.dart';
// import 'package:drift/drift.dart' show Value; // <--- Import necesario para Drift

// import '../../../../features/sales/data/database/sales.dart'; // <--- Import para SaleItemsCompanion
import '../../../../core/database/app_database.dart';
import '../../domain/models/order_item.dart';
import '../../domain/repositories/product_repository.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final ProductRepository _repository;
  final AppDatabase _db; // Referencia a la BD

  // Pedimos ambos en el constructor
  MenuBloc(this._repository, this._db) : super(const MenuState()) {
    
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

    // --- AQUÍ ESTABA EL ERROR ---
    on<ProcessCheckout>((event, emit) async {
      if (state.orderItems.isEmpty) return;

      try {
        // Convertimos la orden de la UI a objetos de la Base de Datos
        final saleItems = state.orderItems.map((item) {
          return SaleItemsCompanion.insert(
            // TRUCO: Drift pide saleId obligatoriamente en .insert.
            // Ponemos 0 porque createSale() lo va a sobrescribir con el ID real.
            saleId: 0, 
            productId: item.product.id,
            productName: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
          );
        }).toList();

        // Guardamos usando la transacción segura
        await _db.createSale(
          total: state.total,
          paymentMethod: 'Efectivo',
          items: saleItems,
        );

        // Limpiamos la pantalla
        emit(state.copyWith(orderItems: [], status: MenuStatus.success));
      } catch (e) {
        emit(state.copyWith(errorMessage: "Error al cobrar: $e"));
      }
    });
  }
}