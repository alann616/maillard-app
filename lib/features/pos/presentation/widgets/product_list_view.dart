import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import 'pos_product_card.dart';

class ProductListView extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAdd;
  final Function(int) getQuantity;
  final bool isLoading;

  const ProductListView({
    super.key,
    required this.products,
    required this.onAdd,
    required this.getQuantity,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        final product = products[i];
        return PosProductCard(
          product: product,
          quantity: getQuantity(product.id),
          onTap: () => onAdd(product),
        );
      },
    );
  }
}