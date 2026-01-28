import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';

class PosTicketItem extends StatelessWidget {
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final VoidCallback onRemove;

  const PosTicketItem({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          "$quantity x \$${price.toStringAsFixed(2)} = \$${total.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }
}