import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Core & Domain Imports
import '../../../../core/database/app_database.dart'; 
import '../../domain/models/order_item.dart';
import '../../domain/repositories/product_repository.dart';

part 'menu_event.dart';
part 'menu_state.dart';

/// Manages the state of the POS Menu Screen.
/// Handles product catalog loading, order manipulation, and interaction
/// with the database for saving pending orders and processing checkouts.
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final ProductRepository _repository;
  final AppDatabase _db;

  MenuBloc(this._repository, this._db) : super(const MenuState()) {
    
    // --- Catalog Management ---

    on<LoadProducts>((event, emit) async {
      emit(state.copyWith(status: MenuStatus.loading));
      try {
        final products = await _repository.getAllProducts();
        emit(state.copyWith(status: MenuStatus.success, products: products));
      } catch (e) {
        emit(state.copyWith(status: MenuStatus.failure, errorMessage: e.toString()));
      }
    });

    // --- Table & Persistence Management ---

    on<SetupTable>((event, emit) async {
      // Always clear local state when switching tables to avoid data pollution
      if (state.tableId != event.tableId) {
        emit(state.copyWith(
          tableId: event.tableId,
          orderItems: [], 
          status: MenuStatus.initial
        ));

        // Attempt to restore pending order from DB
        if (event.tableId > 0) {
          try {
            final pendingData = await _db.getPendingOrder(event.tableId);
            
            if (pendingData != null && pendingData.items.isNotEmpty) {
              // Ensure we have the product catalog loaded to reconstruct OrderItems
              var currentProducts = state.products;
              if (currentProducts.isEmpty) {
                 currentProducts = await _repository.getAllProducts();
              }

              final List<OrderItem> restoredItems = [];

              // Map DB items (SaleItems) back to UI items (OrderItems)
              for (var dbItem in pendingData.items) {
                try {
                  final product = currentProducts.firstWhere((p) => p.id == dbItem.productId);
                  restoredItems.add(OrderItem(product: product, quantity: dbItem.quantity));
                } catch (e) {
                  // Product might have been deleted from catalog; skip or handle accordingly
                }
              }

              emit(state.copyWith(
                orderItems: restoredItems,
                products: currentProducts // Update products in case they were lazy-loaded here
              ));
            }
          } catch (e) {
            // Non-critical error: just start with an empty table
            debugPrint("Warning: Could not restore pending order: $e");
          }
        }
      }
    });

    on<SaveOrder>((event, emit) async {
      if (state.orderItems.isEmpty || state.tableId == null) return;

      try {
        final saleItems = state.orderItems.map((item) {
          return SaleItemsCompanion.insert(
            saleId: 0, // Placeholder, DB handles logic
            productId: item.product.id,
            productName: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
          );
        }).toList();

        // Perform UPSERT operation (Update existing or Insert new pending)
        await _db.savePendingOrder(
          tableId: state.tableId!,
          total: state.total,
          items: saleItems,
        );

        // Notify success but keep items visible for further editing
        emit(state.copyWith(status: MenuStatus.success));
      } catch (e) {
        emit(state.copyWith(errorMessage: "Failed to save order: $e"));
      }
    });

    // --- Order Manipulation ---

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

    // --- Checkout Process ---

    on<ProcessCheckout>((event, emit) async {
      if (state.orderItems.isEmpty) return;

      try {
        final saleItems = state.orderItems.map((item) {
          return SaleItemsCompanion.insert(
            saleId: 0,
            productId: item.product.id,
            productName: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
          );
        }).toList();

        // Finalize sale, update inventory, and close table status
        await _db.completeSale(
          tableId: state.tableId, 
          total: state.total,
          items: saleItems,
        );

        // Clear local state as transaction is complete
        emit(state.copyWith(orderItems: [], status: MenuStatus.success));
      } catch (e) {
        emit(state.copyWith(errorMessage: "Checkout failed: $e"));
      }
    });
  }
}