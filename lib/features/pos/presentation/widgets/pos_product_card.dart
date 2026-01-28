import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';

class PosProductCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;

  const PosProductCard({super.key, required this.product, required this.quantity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: quantity > 0,
              label: Text('$quantity'),
              child: const Icon(Icons.coffee, size: 40, color: Colors.brown),
            ),
            const SizedBox(height: 10),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text('\$${product.price}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}