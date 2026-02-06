

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/inventory/presentation/bloc/inventory_bloc.dart';

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
        heroTag: "btn_add_inventory", // <--- AGREGA ESTO
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showIngredientDialog(context, null),
      ),
      // 2. LISTA DE INSUMOS
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
                return _InventoryTile(
                  ingredient: item,
                  onEdit: () => _showIngredientDialog(context, item),
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
        value: context.read<InventoryBloc>(), // Pasamos el Bloc existente
        child: _IngredientFormDialog(ingredient: ingredient),
      ),
    );
  }
}
/// Tarjeta visual de cada insumo
class _InventoryTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;

  const _InventoryTile({required this.ingredient, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Calculamos si está bajo de stock para ponerlo rojo
    final isLowStock = ingredient.currentStock <= ingredient.minStock;

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
                  Text(
                    "Stock: ${ingredient.currentStock.toStringAsFixed(2)} ${ingredient.unit}",
                    style: TextStyle(
                      color: isLowStock ? Colors.red : Colors.black87,
                      fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    "Mínimo: ${ingredient.minStock} ${ingredient.unit}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Botón Editar (Lápiz)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Formulario para Crear/Editar Insumo
class _IngredientFormDialog extends StatefulWidget {
  final Ingredient? ingredient;
  const _IngredientFormDialog({this.ingredient});

  @override
  State<_IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<_IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl; 
  late TextEditingController _costCtrl;
  late TextEditingController _minStockCtrl;
  late TextEditingController _initialStockCtrl;

  @override
  void initState() {
    super.initState();
    final i = widget.ingredient;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _unitCtrl = TextEditingController(text: i?.unit ?? 'pz');

    _costCtrl = TextEditingController(text: (i?.costPerUnit ?? 0) > 0 ? i!.costPerUnit.toString() : '');
    _minStockCtrl = TextEditingController(text: (i?.minStock ?? 0) > 0 ? i!.minStock.toString() : '');
    _initialStockCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _costCtrl.dispose();
    _minStockCtrl.dispose();
    _initialStockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ingredient != null;

    return AlertDialog(
      title: Text(isEditing ? "Editar Insumo" : "Nuevo Insumo"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nombre *",
                  hintText: "Ej. Café de grano"
                ),
                validator: (v) => v!.isEmpty ? "El nombre es requerido" : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(
                  labelText: "Unidad *",
                  hintText: "Ej. Kg, g, oz, L, ml"
                ),
                validator: (v) => v!.isEmpty ? "La unidad es requerida" : null,
              ),
              
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      decoration: const InputDecoration(
                        labelText: "Costo",
                        hintText: "0.00",
                        prefixText: "\$",
                        helperText: "Opcional"
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      validator: (v) {
                        if (v!.isEmpty) return null; 
                        if (double.tryParse(v) == null) return "Inválido";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockCtrl,
                      decoration: const InputDecoration(
                        labelText: "Alerta Stock",
                        hintText: "0",
                        helperText: "Opcional"
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (!isEditing) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _initialStockCtrl,
                  decoration: const InputDecoration(
                    labelText: "Stock Inicial", 
                    helperText: "¿Cuánto tienes hoy?"
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: () => _confirmDelete(context),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancelar")
        ),
        
        FilledButton(
          onPressed: _submit, 
          child: const Text("Guardar")
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text;
      final unit = _unitCtrl.text;
      final cost = double.tryParse(_costCtrl.text) ?? 0.0;
      final minStock = double.tryParse(_minStockCtrl.text) ?? 0.0;

      if (widget.ingredient != null) {
        // EDITAR
        final updated = Ingredient(
          id: widget.ingredient!.id,
          name: name,
          unit: unit,
          costPerUnit: cost,
          minStock: minStock,
          currentStock: widget.ingredient!.currentStock,
        );
        context.read<InventoryBloc>().add(EditIngredientEvent(updated));
      } else {
        // CREAR
        final initial = double.tryParse(_initialStockCtrl.text) ?? 0.0;
        context.read<InventoryBloc>().add(CreateIngredientEvent(
          name: name,
          unit: unit,
          cost: cost,
          minStock: minStock,
          initialStock: initial
        ));
      }
      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext ctxParent) {
    showDialog(
      context: ctxParent,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar Insumo?"),
        content: Text("Se borrará '${widget.ingredient!.name}' permanentemente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              // Usamos el context del padre (que tiene acceso al Bloc)
              ctxParent.read<InventoryBloc>().add(DeleteIngredientEvent(widget.ingredient!.id));
              Navigator.pop(ctx); // Cerrar alerta confirmación
              Navigator.pop(ctxParent); // Cerrar formulario
            }, 
            child: const Text("Eliminar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}

