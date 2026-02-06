import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:app/core/database/app_database.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final Ingredient ingredient;
  const StockAdjustmentDialog({super.key, required this.ingredient});

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  final _controller = TextEditingController();
  bool _isAdding = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Ajustar: ${widget.ingredient.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Stock Actual: ${widget.ingredient.currentStock} ${widget.ingredient.unit}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ToggleButtons(
                isSelected: [_isAdding, !_isAdding],
                onPressed: (index) {
                  setState(() {
                    _isAdding = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.add, color: Colors.green)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.remove, color: Colors.red)),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: "Cantidad",
                    suffixText: widget.ingredient.unit,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        FilledButton(
          onPressed: () {
            final quantity = double.tryParse(_controller.text);
            if (quantity != null && quantity > 0) {
              final finalQty = _isAdding ? quantity : -quantity;
              context.read<InventoryBloc>().add(
                UpdateStock(widget.ingredient.id, finalQty)
              );
              Navigator.pop(context);
            }
          },
          child: Text(_isAdding ? "Agregar" : "Descontar"),
        ),
      ],
    );
  }
}