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
  final VoidCallback onSave; // <--- NUEVO CALLBACK

  const TicketSidebar({
    super.key,
    required this.order,
    required this.total,
    required this.onRemove,
    required this.onCheckout,
    required this.onSave, // <--- REQUERIDO
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20), 
          child: Text("TU ORDEN", style: AppTheme.titleLarge)
        ),
        Expanded(
          child: order.isEmpty 
          ? const Center(child: Text("Ticket Vacío"))
          : ListView.separated(
              itemCount: order.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (ctx, i) {
                final item = order[i];
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
        _TicketFooter(
          total: total, 
          onCheckout: onCheckout, 
          onSave: onSave, // Pasamos el evento
          hasItems: order.isNotEmpty
        ),
      ],
    );
  }
}

class _TicketFooter extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  final VoidCallback onSave; // <--- NUEVO
  final bool hasItems;

  const _TicketFooter({
    required this.total, 
    required this.onCheckout, 
    required this.onSave, // <---
    required this.hasItems
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Column(
        children: [
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
          
          // --- NUEVO DISEÑO DE BOTONES ---
          Row(
            children: [
              // Botón GUARDAR (Outline Naranja)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), // Altura similar al PrimaryButton
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: hasItems ? onSave : null,
                  child: const Text("GUARDAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ),
              ),
              const SizedBox(width: 10),
              // Botón COBRAR (Primary)
              Expanded(
                child: PrimaryButton(
                  text: "COBRAR", 
                  // icon: Icons.attach_money, // Opcional, quité el icono para que quepa mejor el texto
                  onPressed: hasItems ? onCheckout : null
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}