import 'package:flutter/material.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/features/pos/presentation/screens/tables_screen.dart';
import 'package:app/features/pos/presentation/screens/admin_products_screen.dart';
import 'package:app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:app/features/sales/presentation/screens/sales_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Las 4 pantallas principales de la App
  static const List<Widget> _screens = [
    TablesScreen(),        // Index 0: Caja (Operación)
    AdminProductsScreen(), // Index 1: Menú (Gestión)
    InventoryScreen(),     // Index 2: Inventario (Compras)
    SalesHistoryScreen(),  // Index 3: Reportes (Dinero)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack es ideal porque mantiene la memoria de cada pestaña
      // (ej. si dejas una compra a medias en Inventario, no se borra al cambiar de tab)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.2),
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale, color: AppTheme.primary),
            label: 'Caja',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: AppTheme.primary),
            label: 'Menú',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppTheme.primary),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: AppTheme.primary),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}