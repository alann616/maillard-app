part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object> get props => [];
}

class LoadProducts extends MenuEvent {}
class AddProductToOrder extends MenuEvent { final Product product; const AddProductToOrder(this.product); }
class RemoveProductFromOrder extends MenuEvent { final Product product; const RemoveProductFromOrder(this.product); }
class ProcessCheckout extends MenuEvent {}