import 'package:equatable/equatable.dart';

// CORRECCIÓN 2: Importar la DB correcta en 'data/database'
import '../../data/database/app_database.dart';

class OrderItem extends Equatable {
  final Product product;
  final int quantity;

  const OrderItem({required this.product, required this.quantity});

  double get total => product.price * quantity;

  OrderItem copyWith({Product? product, int? quantity}) {
    return OrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  OrderItem increment() => copyWith(quantity: quantity + 1);
  OrderItem decrement() => copyWith(quantity: quantity - 1);

  @override
  List<Object?> get props => [product.id, quantity];
}