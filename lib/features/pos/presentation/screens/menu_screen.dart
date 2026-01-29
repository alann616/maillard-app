import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Imports propios
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/role_guard.dart';
import '../../../pos/domain/models/user_role.dart';
import '../../presentation/widgets/ticket_sidebar.dart';
import '../bloc/menu_bloc.dart'; // Importa SaveOrder aquí
import '../widgets/product_list_view.dart';

class MenuScreen extends StatelessWidget {
  final String tableId;
  const MenuScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    final int id = int.tryParse(tableId) ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuBloc>().add(SetupTable(id));
    });
    
    return const _MenuScreenView();
  }
}

class _MenuScreenView extends StatelessWidget {
  const _MenuScreenView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MenuBloc>().state;

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text("Punto de Venta"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          RoleGuard(
            allowedRoles: const [UserRole.admin],
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () { /* Ir a ajustes */ },
            ),
          ),
        ],
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: const [UserRole.admin],
        child: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("¡Hola Jefe! Aquí crearás productos.")),
            );
          },
        ),
      ),
      body: state.status == MenuStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : MediaQuery.of(context).size.width > 600
          ? _buildTabletLayout(context, state)
          : _buildMobileLayout(context, state),
    );
  }

  // --- LAYOUT TABLET ---
  Widget _buildTabletLayout(BuildContext context, MenuState state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ProductListView(
            products: state.products,
            onAdd: (p) => context.read<MenuBloc>().add(AddProductToOrder(p)),
            getQuantity: (id) => state.getQuantity(id),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            // Aquí conectamos el nuevo evento onSave
            child: TicketSidebar(
              order: state.orderItems,
              total: state.total,
              onRemove: (idx) => context.read<MenuBloc>().add(
                RemoveProductFromOrder(state.orderItems[idx].product),
              ),
              onCheckout: () => context.read<MenuBloc>().add(ProcessCheckout()),
              // NUEVO: Conectamos Guardar
              onSave: () {
                context.read<MenuBloc>().add(SaveOrder());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Comanda Guardada 📝"), backgroundColor: Colors.orange),
                );
                Navigator.pop(context); // Salir al mapa
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- LAYOUT MÓVIL ---
  Widget _buildMobileLayout(BuildContext context, MenuState state) {
    return Stack(
      children: [
        ProductListView(
          products: state.products,
          onAdd: (p) => context.read<MenuBloc>().add(AddProductToOrder(p)),
          getQuantity: (id) => state.getQuantity(id),
        ),
        if (state.orderItems.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: PrimaryButton(
              text: "Ver Comanda (\$${state.total.toStringAsFixed(2)})",
              icon: Icons.receipt,
              onPressed: () {
                _showTicketSheet(context);
              },
            ),
          ),
      ],
    );
  }

  void _showTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<MenuBloc>(),
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              return FractionallySizedBox(
                heightFactor: 0.85,
                child: TicketSidebar(
                  order: state.orderItems,
                  total: state.total,
                  onRemove: (idx) {
                    final product = state.orderItems[idx].product;
                    context.read<MenuBloc>().add(RemoveProductFromOrder(product));
                  },
                  onCheckout: () {
                    context.read<MenuBloc>().add(ProcessCheckout());
                    Navigator.pop(context);
                  },
                  // NUEVO: Conectamos Guardar en Móvil también
                  onSave: () {
                    context.read<MenuBloc>().add(SaveOrder());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Comanda Guardada 📝"), backgroundColor: Colors.orange),
                    );
                    Navigator.pop(context); // Cierra el Sheet
                    Navigator.pop(context); // Sale al mapa (Opcional, si quieres que te saque de la mesa)
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}