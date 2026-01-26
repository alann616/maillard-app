import 'package:go_router/go_router.dart';
import 'package:app/features/pos/presentation/screens/menu_screen.dart';
import 'package:app/features/pos/presentation/screens/tables_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Ruta Principal: Mapa de Mesas
    GoRoute(
      path: '/',
      builder: (context, state) => const TablesScreen(),
    ),
    // Ruta Secundaria: Menú (recibe el ID de la mesa)
    GoRoute(
      path: '/menu/:tableId',
      builder: (context, state) {
        // Obtenemos el ID de la URL (ej: /menu/5 -> tableId = 5)
        final tableId = state.pathParameters['tableId'] ?? '1';
        return MenuScreen(tableId: tableId);
      },
    ),
  ],
);