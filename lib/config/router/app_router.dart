import 'package:go_router/go_router.dart';
import 'package:app/features/pos/presentation/screens/menu_screen.dart';
import 'package:app/features/pos/presentation/screens/tables_screen.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart'; // Import nuevo

final appRouter = GoRouter(
  initialLocation: '/login', // <--- CAMBIO IMPORTANTE: Ahora inicia en login
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const TablesScreen(),
    ),
    GoRoute(
      path: '/menu/:tableId',
      builder: (context, state) {
        final tableId = state.pathParameters['tableId'] ?? '1';
        return MenuScreen(tableId: tableId);
      },
    ),
  ],
);