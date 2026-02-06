import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/inventory/presentation/bloc/inventory_bloc.dart';

import 'package:app/features/inventory/presentation/widgets/inventory_tile.dart';
import 'package:app/features/inventory/presentation/widgets/ingredient_form_dialog.dart';
import 'package:app/features/inventory/presentation/widgets/stock_adjustment_dialog.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text("Inventario"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn_add_inventory",
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showIngredientDialog(context, null),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InventoryLoaded) {
            if (state.ingredients.isEmpty) {
              return const Center(child: Text("Tu alacena está vacía 🕸️"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.ingredients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = state.ingredients[index];
                
                // Usamos el widget importado (limpio y público)
                return InventoryTile(
                  ingredient: item,
                  onEdit: () => _showIngredientDialog(context, item),
                  onAdjustStock: () => _showStockDialog(context, item),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showIngredientDialog(BuildContext context, Ingredient? ingredient) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: IngredientFormDialog(ingredient: ingredient),
      ),
    );
  }

  void _showStockDialog(BuildContext context, Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<InventoryBloc>(),
        child: StockAdjustmentDialog(ingredient: ingredient),
      ),
    );
  }
}