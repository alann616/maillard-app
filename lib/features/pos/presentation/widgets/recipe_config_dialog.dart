import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/repositories/product_repository.dart';
import '../bloc/recipe/recipe_bloc.dart';

class RecipeConfigDialog extends StatefulWidget {
  final int productId;
  const RecipeConfigDialog({super.key, required this.productId});

  @override
  State<RecipeConfigDialog> createState() => _RecipeConfigDialogState();
}

class _RecipeConfigDialogState extends State<RecipeConfigDialog> {
  List<RecipeDTO> _localRecipe = [];
  bool _isLoaded = false;

  Ingredient? _selectedIngredient;
  final _qtyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadRecipe(widget.productId));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_selectedIngredient == null || _qtyCtrl.text.isEmpty) return;

    final qty = double.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) return;

    setState(() {
      _localRecipe.add(RecipeDTO(_selectedIngredient!.id, qty));
      _selectedIngredient = null;
      _qtyCtrl.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _localRecipe.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeSavedSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Receta guardada ✅"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is RecipeLoading) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is RecipeLoaded) {
          if (!_isLoaded) {
            _localRecipe = List.from(state.currentRecipe);
            _isLoaded = true;
          }

          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Configurar Receta", style: TextStyle(fontSize: 18)),
                Text(
                  state.product.name,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Insumo",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Ingredient>(
                                isExpanded: true,
                                isDense: true,
                                value: _selectedIngredient,
                                items: state.allIngredients.map((ing) {
                                  return DropdownMenuItem(
                                    value: ing,
                                    child: Text(
                                      ing.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedIngredient = val),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Cant",
                              suffixText: _selectedIngredient?.unit ?? '',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add),
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Divider(),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ingredientes:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),

                  Flexible(
                    child: _localRecipe.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "Este producto no descuenta inventario.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _localRecipe.length,
                            itemBuilder: (context, index) {
                              final recipeItem = _localRecipe[index];

                              // Buscamos el ingrediente de forma segura
                              final ingredient = state.allIngredients
                                  .firstWhere(
                                    (i) => i.id == recipeItem.ingredientId,
                                    orElse: () => const Ingredient(
                                      id: -1,
                                      name: 'Desconocido',
                                      unit: '',
                                      currentStock: 0,
                                      costPerUnit: 0,
                                      minStock: 0,
                                    ),
                                  );

                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: AppTheme.primary,
                                ),
                                title: Text(ingredient.name),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${recipeItem.quantity} ${ingredient.unit}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _removeIngredient(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              FilledButton(
                onPressed: () {
                  if (_selectedIngredient != null && _qtyCtrl.text.isNotEmpty) {
                    final qty = double.tryParse(_qtyCtrl.text);
                    if (qty != null && qty > 0) {
                      _localRecipe.add(RecipeDTO(_selectedIngredient!.id, qty));
                    }
                  }

                  context.read<RecipeBloc>().add(
                    SaveRecipe(widget.productId, _localRecipe),
                  );
                },
                child: const Text("Guardar Receta"),
              ),
            ],
          );
        }

        if (state is RecipeError) {
          return AlertDialog(content: Text(state.message));
        }

        return const SizedBox.shrink();
      },
    );
  }
}
