import 'package:app/features/pos/presentation/widgets/ticket_sidebard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../bloc/menu_bloc.dart';
import '../widgets/product_list_view.dart';

class MenuScreen extends StatelessWidget {
  final String tableId;
  const MenuScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el BLoC aquí
    return RepositoryProvider(
      create: (context) => ProductRepositoryImpl(AppDatabase()),
      child: BlocProvider(
        create: (context) => MenuBloc(context.read<ProductRepositoryImpl>())..add(LoadProducts()),
        child: const _MenuScreenView(),
      ),
    );
  }
}

class _MenuScreenView extends StatelessWidget {
  const _MenuScreenView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MenuBloc>().state;

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(title: const Text("Punto de Venta"), backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
      body: state.status == MenuStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : MediaQuery.of(context).size.width > 600
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state),
    );
  }

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
            child: TicketSidebar(
              order: state.orderItems,
              total: state.total,
              onRemove: (idx) => context.read<MenuBloc>().add(RemoveProductFromOrder(state.orderItems[idx].product)),
              onCheckout: () => context.read<MenuBloc>().add(ProcessCheckout()),
            ),
          ),
        ),
      ],
    );
  }

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
            bottom: 20, left: 20, right: 20,
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
      isScrollControlled: true, // Permite que crezca si hay muchos items
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (_) {
        // Usamos BlocProvider.value para pasar el BLoC existente al modal
        return BlocProvider.value(
          value: context.read<MenuBloc>(),
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              return FractionallySizedBox(
                heightFactor: 0.85, // Ocupa el 85% de la pantalla
                child: TicketSidebar(
                  order: state.orderItems,
                  total: state.total,
                  onRemove: (idx) {
                    final product = state.orderItems[idx].product;
                    context.read<MenuBloc>().add(RemoveProductFromOrder(product));
                  },
                  onCheckout: () {
                    context.read<MenuBloc>().add(ProcessCheckout());
                    Navigator.pop(context); // Cierra el modal al cobrar
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