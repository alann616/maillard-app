import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/models/order_item.dart';
import 'pos_ticket_item.dart';

class TicketSidebar extends StatelessWidget {
  final List<OrderItem> order;
  final double total;
  final Function(int) onRemove;
  final VoidCallback onCheckout;

  const TicketSidebar({
    super.key,
    required this.order,
    required this.total,
    required this.onRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(20), child: Text("TU ORDEN", style: AppTheme.titleLarge)),
        Expanded(
          child: order.isEmpty 
          ? const Center(child: Text("Ticket Vacío"))
          : ListView.separated(
              itemCount: order.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final item = order[i];
                // Usamos el widget atómico que acabamos de crear
                return PosTicketItem(
                  productName: item.product.name,
                  price: item.product.price,
                  quantity: item.quantity,
                  total: item.total,
                  onRemove: () => onRemove(i),
                );
              },
            ),
        ),
        _TicketFooter(total: total, onCheckout: onCheckout, hasItems: order.isNotEmpty),
      ],
    );
  }
}

class _TicketFooter extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  final bool hasItems;

  const _TicketFooter({required this.total, required this.onCheckout, required this.hasItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        children: [
          // FIX VISUAL: FittedBox para evitar overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TOTAL", style: AppTheme.titleLarge),
                const SizedBox(width: 20),
                Text("\$${total.toStringAsFixed(2)}", style: AppTheme.priceTag),
              ],
            ),
          ),
          const SizedBox(height: 15),
          PrimaryButton(text: "COBRAR", icon: Icons.attach_money, onPressed: hasItems ? onCheckout : null),
        ],
      ),
    );
  }
}