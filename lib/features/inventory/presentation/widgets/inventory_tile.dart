import 'package:flutter/material.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/core/database/app_database.dart';

class InventoryTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onAdjustStock;

  const InventoryTile({
    super.key,
    required this.ingredient, 
    required this.onEdit,
    required this.onAdjustStock,
  });

  // 👇 FUNCIÓN MAGICA PARA QUITAR DECIMALES INNECESARIOS
  String _formatNumber(double value) {
    // Si el residuo de dividir entre 1 es 0, es un entero (12.0 -> 12)
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    // Si tiene decimales, mostramos hasta 2, pero quitamos ceros a la derecha si sobran
    return value.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = ingredient.currentStock <= ingredient.minStock;

    // Formateamos los números antes de usarlos
    final stockDisplay = _formatNumber(ingredient.currentStock);
    final minDisplay = _formatNumber(ingredient.minStock);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icono / Indicador
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLowStock ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                color: isLowStock ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            
            // Datos del Insumo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  // 👇 AQUI USAMOS EL FORMATO LIMPIO
                  Text(
                    "Stock: $stockDisplay ${ingredient.unit}",
                    style: TextStyle(
                      color: isLowStock ? Colors.red : Colors.black87,
                      fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    "Mínimo: $minDisplay ${ingredient.unit}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // BOTONES DE ACCIÓN
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.exposure, color: AppTheme.primary),
                  tooltip: "Ajustar Stock",
                  onPressed: onAdjustStock,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  tooltip: "Editar Detalles",
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}