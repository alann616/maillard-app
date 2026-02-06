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
  bool _isAdding = true; // true = sumar, false = restar
  bool _usePackage = false; // ¿Usar unidad de empaque? (ej. Botella)

  @override
  void initState() {
    super.initState();
    // Si tiene empaque, sugerimos usarlo por defecto si es una suma (llega stock)
    if ((widget.ingredient.packageSize ?? 0) > 0) {
      _usePackage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPackage = (widget.ingredient.packageSize ?? 0) > 0;
    final packageUnit = widget.ingredient.purchaseUnit ?? 'Empaque';
    final baseUnit = widget.ingredient.unit;

    return AlertDialog(
      title: Text("Ajustar: ${widget.ingredient.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Stock Actual
          Text(
            "Stock Actual: ${widget.ingredient.currentStock} $baseUnit",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Selector de Unidad (Solo si tiene empaque configurado)
          if (hasPackage) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildUnitTab(baseUnit, false),
                  _buildUnitTab(packageUnit, true),
                ],
              ),
            ),
          ],

          Row(
            children: [
              // Toggle Sumar/Restar
              ToggleButtons(
                isSelected: [_isAdding, !_isAdding],
                onPressed: (index) {
                  setState(() {
                    _isAdding = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
                children: const [
                  Icon(Icons.add, color: Colors.green),
                  Icon(Icons.remove, color: Colors.red),
                ],
              ),
              const SizedBox(width: 15),
              // Input Cantidad
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: "Cantidad",
                    // Cambia dinámicamente según lo que seleccionó
                    suffixText: _usePackage ? packageUnit : baseUnit,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ),
            ],
          ),

          // Mensaje de conversión informativa
          if (_usePackage && hasPackage)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                // Usamos un Builder para recalcular el texto en tiempo real si fuera necesario, o simplificamos
                "Estás ${_isAdding ? 'agregando' : 'quitando'} equivalentes a ${_calculateTotal()} $baseUnit",
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isAdding ? "Agregar" : "Descontar"),
        ),
      ],
    );
  }

  String _calculateTotal() {
    final qty = double.tryParse(_controller.text) ?? 0;
    if (widget.ingredient.packageSize != null) {
      return (qty * widget.ingredient.packageSize!).toStringAsFixed(1);
    }
    return "0";
  }

  Widget _buildUnitTab(String text, bool isPackage) {
    final isSelected = _usePackage == isPackage;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _usePackage = isPackage),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final qty = double.tryParse(_controller.text);
    if (qty != null && qty > 0) {
      double finalQty = qty;

      // 🧠 LA MAGIA: CONVERSIÓN AUTOMÁTICA
      if (_usePackage && widget.ingredient.packageSize != null) {
        finalQty = qty * widget.ingredient.packageSize!;
      }

      // Aplicar signo (+/-)
      if (!_isAdding) finalQty = -finalQty;

      context.read<InventoryBloc>().add(
        UpdateStock(widget.ingredient.id, finalQty),
      );
      Navigator.pop(context);
    }
  }
}
