import 'package:app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:app/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/pos/presentation/screens/menu_screen.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import '../../features/pos/presentation/screens/admin_products_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login', // <--- CAMBIO IMPORTANTE: Ahora inicia en login
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/menu/:tableId',
      builder: (context, state) {
        final tableId = state.pathParameters['tableId'] ?? '1';
        return MenuScreen(tableId: tableId);
      },
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesHistoryScreen(),
      ),
    GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),  
  ],
);