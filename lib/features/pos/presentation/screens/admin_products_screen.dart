import 'package:app/core/database/app_database.dart';
import 'package:app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:app/features/pos/data/repositories/product_repository_impl.dart';
import 'package:app/features/pos/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../bloc/product_management/product_management_bloc.dart';
import '../widgets/recipe_config_dialog.dart';

/// Pantalla principal para la administración de productos (CRUD).
/// Permite crear, editar, eliminar y configurar recetas de productos.
class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialización: Carga la lista de productos al montar la vista.
    context.read<ProductManagementBloc>().add(LoadAdminProducts());

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text("Administrar Menú"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showProductDialog(context, null),
      ),
      // Escucha cambios de estado para mostrar feedback visual (Snackbars)
      body: BlocListener<ProductManagementBloc, ProductManagementState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is ProductManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        // Construye la lista basada en el estado actual
        child: BlocBuilder<ProductManagementBloc, ProductManagementState>(
          builder: (context, state) {
            if (state is ProductManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductManagementLoaded) {
              if (state.products.isEmpty) {
                return const Center(child: Text("No hay productos registrados."));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return _AdminProductTile(product: product);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Muestra el diálogo para crear o editar un producto básico (Nombre, Precio, Categoría).
  void _showProductDialog(BuildContext context, Product? product) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductManagementBloc>(),
        child: _ProductFormDialog(product: product),
      ),
    );
  }
}

/// Tarjeta individual que representa un producto en la lista.
/// Contiene las acciones de Editar Receta, Editar Datos y Eliminar.
class _AdminProductTile extends StatelessWidget {
  final Product product;
  const _AdminProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Text(
            product.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${product.category} • \$${product.price.toStringAsFixed(2)}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón: Configurar Receta
            IconButton(
              icon: const Icon(Icons.science, color: Colors.purple),
              tooltip: "Configurar Receta",
              onPressed: () async {
                // Inyectamos RecipeBloc exclusivamente para el ciclo de vida del diálogo
                await showDialog(
                  context: context,
                  builder: (_) => BlocProvider(
                    create: (ctx) => RecipeBloc(
                      ctx.read<ProductRepositoryImpl>(),
                      ctx.read<InventoryRepositoryImpl>(),
                    ),
                    child: RecipeConfigDialog(productId: product.id),
                  ),
                );
                
                // Al cerrar el diálogo, refrescamos la lista principal para asegurar consistencia
                if (context.mounted) {
                  context.read<ProductManagementBloc>().add(LoadAdminProducts());
                }
              },
            ),
            // Botón: Editar Producto
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: context.read<ProductManagementBloc>(),
                    child: _ProductFormDialog(product: product),
                  ),
                );
              },
            ),
            // Botón: Eliminar Producto
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar producto?"),
        content: Text("Se eliminará '${product.name}' permanentemente."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              context.read<ProductManagementBloc>().add(DeleteProductEvent(product.id));
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Formulario para Crear/Actualizar datos básicos del producto.
class _ProductFormDialog extends StatefulWidget {
  final Product? product;
  const _ProductFormDialog({this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _catCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _catCtrl = TextEditingController(text: widget.product?.category ?? 'General');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? "Editar Producto" : "Nuevo Producto"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
              validator: (v) => v!.isEmpty ? "Campo requerido" : null,
            ),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: "Precio"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => double.tryParse(v!) == null ? "Precio inválido" : null,
            ),
            TextFormField(
              controller: _catCtrl,
              decoration: const InputDecoration(labelText: "Categoría"),
              validator: (v) => v!.isEmpty ? "Campo requerido" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameCtrl.text;
              final price = double.parse(_priceCtrl.text);
              final category = _catCtrl.text;

              if (isEditing) {
                // Actualizar existente
                final updatedProduct = Product(
                  id: widget.product!.id, 
                  name: name, 
                  price: price, 
                  category: category
                );
                context.read<ProductManagementBloc>().add(UpdateProductEvent(updatedProduct));
              } else {
                // Crear nuevo
                context.read<ProductManagementBloc>().add(CreateProductEvent(
                  name: name, 
                  price: price, 
                  category: category
                ));
              }
              Navigator.pop(context);
            }
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}