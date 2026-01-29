import 'package:app/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../bloc/inventory_bloc.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario en Vivo")),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InventoryLoaded) {
            if (state.ingredients.isEmpty) return const Center(child: Text("Sin insumos"));
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.ingredients.length,
              itemBuilder: (context, index) {
                final item = state.ingredients[index];
                return _InventoryItemCard(item: item);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final Ingredient item;
  const _InventoryItemCard({required this.item});

  // Función para mostrar el diálogo de "Comprar Stock"
  void _showAddStockDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Resurtir ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Stock actual: ${item.currentStock} ${item.unit}"),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: "Cantidad a agregar (${item.unit})",
                border: const OutlineInputBorder(),
                suffixText: item.unit,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              final quantity = double.tryParse(controller.text);
              if (quantity != null && quantity > 0) {
                // 1. Disparamos el evento al Bloc (Usamos el context original, no el del dialogo)
                context.read<InventoryBloc>().add(AddStock(item.id, quantity));
                // 2. Cerramos y mostramos confirmación
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Se agregaron $quantity ${item.unit} a ${item.name}")),
                );
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = item.currentStock <= item.minStock;
    final statusBg = isLowStock 
        ? AppTheme.error.withValues(alpha: 0.1) 
        : Colors.green.withValues(alpha: 0.1);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row( // Usamos Row para poner el botón a la derecha
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(
                      "${item.currentStock.toStringAsFixed(1)} ${item.unit}",
                      style: TextStyle(
                        color: isLowStock ? AppTheme.error : Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    backgroundColor: statusBg,
                    padding: EdgeInsets.zero,
                  ),
                  if (isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "⚠️ Stock Bajo (Mín: ${item.minStock} ${item.unit})",
                        style: const TextStyle(color: AppTheme.error, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            // --- EL BOTÓN MÁGICO ---
            IconButton.filledTonal(
              icon: const Icon(Icons.add),
              tooltip: "Resurtir",
              onPressed: () => _showAddStockDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}