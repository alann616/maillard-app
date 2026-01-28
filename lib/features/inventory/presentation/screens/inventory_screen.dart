import 'package:app/core/database/app_database.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    // Calculamos porcentaje para la barra (asumiendo un máximo arbitrario o minStock)
    // Para visualización simple, usaremos un valor visual
    final isLowStock = item.currentStock <= item.minStock;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Chip(
                  label: Text(
                    "${item.currentStock.toStringAsFixed(1)} ${item.unit}",
                    style: TextStyle(
                      color: isLowStock ? AppTheme.error : Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  backgroundColor: isLowStock ? AppTheme.error.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                )
              ],
            ),
            if (isLowStock)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "⚠️ Stock Bajo (Mín: ${item.minStock} ${item.unit})",
                  style: const TextStyle(color: AppTheme.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}