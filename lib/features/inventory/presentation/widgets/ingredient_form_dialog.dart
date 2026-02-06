import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:app/core/database/app_database.dart';

class IngredientFormDialog extends StatefulWidget {
  final Ingredient? ingredient;
  const IngredientFormDialog({super.key, this.ingredient});

  @override
  State<IngredientFormDialog> createState() => _IngredientFormDialogState();
}

class _IngredientFormDialogState extends State<IngredientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl; 
  late TextEditingController _costCtrl;
  late TextEditingController _minStockCtrl;
  late TextEditingController _initialStockCtrl;
  bool _hasPackage = false;
  late TextEditingController _packageUnitCtrl; // Ej: "Botella"
  late TextEditingController _packageSizeCtrl; // Ej: "750"

  @override
  void initState() {
    super.initState();
    final i = widget.ingredient;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _unitCtrl = TextEditingController(text: i?.unit ?? 'pz');
    
    _costCtrl = TextEditingController(text: (i?.costPerUnit ?? 0) > 0 ? i!.costPerUnit.toString() : '');
    _minStockCtrl = TextEditingController(text: (i?.minStock ?? 0) > 0 ? i!.minStock.toString() : '');
    _initialStockCtrl = TextEditingController(text: ''); 

    _hasPackage = (i?.packageSize ?? 0) > 0;
    _packageUnitCtrl = TextEditingController(text: i?.purchaseUnit ?? '');
    _packageSizeCtrl = TextEditingController(text: (i?.packageSize ?? 0) > 0 ? i!.packageSize.toString() : '');
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
                validator: (v) => v!.trim().isEmpty ? "El nombre es requerido" : null,
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(
                  labelText: "Unidad *",
                  hintText: "Ej. Kg, g, oz, L, ml"
                ),
                validator: (v) => v!.trim().isEmpty ? "La unidad es requerida" : null,
              ),
              
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("¿Se compra por paquete?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Ej: Botellas, Cajas, Bolsas...", style: TextStyle(fontSize: 12)),
                      value: _hasPackage,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _hasPackage = val);
                      },
                    ),
                    if (_hasPackage) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _packageUnitCtrl,
                              decoration: const InputDecoration(
                                labelText: "Empaque",
                                hintText: "Ej. Botella"
                              ),
                              validator: (v) => _hasPackage && v!.isEmpty ? "Requerido" : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _packageSizeCtrl,
                              decoration: const InputDecoration(
                                labelText: "Contenido",
                                hintText: "Ej. 750"
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                              validator: (v) => _hasPackage && v!.isEmpty ? "Requerido" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "1 ${_packageUnitCtrl.text.isEmpty ? 'Empaque' : _packageUnitCtrl.text} = ${_packageSizeCtrl.text.isEmpty ? '?' : _packageSizeCtrl.text} ${_unitCtrl.text}",
                        style: TextStyle(color: Colors.blue[800], fontSize: 12, fontStyle: FontStyle.italic),
                      )
                    ]
                  ],
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      decoration: const InputDecoration(
                        labelText: "Costo",
                        hintText: "0.00",
                        prefixText: "\$ ",
                        helperText: "Opcional"
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      validator: (v) {
                        if (v!.isEmpty) return null; 
                        if (double.tryParse(v) == null) return "Solo números"; 
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
                      validator: (v) {
                        if (v!.isEmpty) return null; 
                        if (double.tryParse(v) == null) return "Solo números"; 
                        return null;
                      },
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
                  validator: (v) {
                    if (v!.isEmpty) return null; 
                    if (double.tryParse(v) == null) return "Solo números"; 
                    return null;
                  },
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
      // Recopilar datos
      final name = _nameCtrl.text.trim();
      final unit = _unitCtrl.text.trim();
      final cost = double.tryParse(_costCtrl.text) ?? 0.0;
      final minStock = double.tryParse(_minStockCtrl.text) ?? 0.0;

      // Datos de empaque (si aplica)
      final purchaseUnit = _hasPackage ? _packageUnitCtrl.text.trim() : null;
      final packageSize = _hasPackage ? double.tryParse(_packageSizeCtrl.text) : null;

      if (widget.ingredient != null) {
        final updated = Ingredient(
          id: widget.ingredient!.id,
          name: name,
          unit: unit,
          costPerUnit: cost,
          minStock: minStock,
          currentStock: widget.ingredient!.currentStock,
          purchaseUnit: purchaseUnit,
          packageSize: packageSize,
        );
        context.read<InventoryBloc>().add(EditIngredientEvent(updated));
      } else {
        final initial = double.tryParse(_initialStockCtrl.text) ?? 0.0;
        context.read<InventoryBloc>().add(CreateIngredientEvent(
          name: name,
          unit: unit,
          cost: cost,
          minStock: minStock,
          initialStock: initial,
          purchaseUnit: purchaseUnit,
          packageSize: packageSize,
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
              ctxParent.read<InventoryBloc>().add(DeleteIngredientEvent(widget.ingredient!.id));
              Navigator.pop(ctx);
              Navigator.pop(ctxParent);
            }, 
            child: const Text("Eliminar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}