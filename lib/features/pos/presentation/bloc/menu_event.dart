part of 'menu_bloc.dart';

/// Base class for all events related to the POS Menu.
sealed class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

/// Triggers the initial loading of the product catalog from the repository.
class LoadProducts extends MenuEvent {}

/// Adds a specific [product] to the current order.
/// If the product already exists, it increments the quantity.
class AddProductToOrder extends MenuEvent {
  final Product product;
  const AddProductToOrder(this.product);

  @override
  List<Object> get props => [product];
}

/// Removes a specific [product] from the current order.
/// If quantity > 1, it decrements; otherwise, removes the item.
class RemoveProductFromOrder extends MenuEvent {
  final Product product;
  const RemoveProductFromOrder(this.product);

  @override
  List<Object> get props => [product];
}

/// Initializes the menu for a specific table.
/// It clears any previous temporary state and attempts to restore
/// a pending order from the database if one exists for [tableId].
class SetupTable extends MenuEvent {
  final int tableId;
  const SetupTable(this.tableId);
  
  @override
  List<Object> get props => [tableId];
}

/// Persists the current order to the database without closing the sale.
/// Used for "Send to Kitchen" functionality.
/// Status becomes [SaleStatus.pending] in the database.
class SaveOrder extends MenuEvent {}

/// Finalizes the transaction.
/// Converts the pending order to a completed sale, updates inventory,
/// and clears the local state.
class ProcessCheckout extends MenuEvent {}