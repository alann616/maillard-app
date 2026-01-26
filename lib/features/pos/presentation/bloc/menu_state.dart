part of 'menu_bloc.dart';

enum MenuStatus { initial, loading, success, failure }

class MenuState extends Equatable {
  final MenuStatus status;
  final List<Product> products;
  final List<OrderItem> orderItems;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.products = const [],
    this.orderItems = const [],
    this.errorMessage,
  });

  double get total => orderItems.fold(0, (sum, item) => sum + item.total);

  int getQuantity(int productId) {
    final index = orderItems.indexWhere((item) => item.product.id == productId);
    return index != -1 ? orderItems[index].quantity : 0;
  }

  MenuState copyWith({
    MenuStatus? status,
    List<Product>? products,
    List<OrderItem>? orderItems,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      products: products ?? this.products,
      orderItems: orderItems ?? this.orderItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, orderItems, errorMessage];
}