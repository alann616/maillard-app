import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:app/features/pos/presentation/bloc/table_bloc.dart';
import 'package:app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/pos/presentation/bloc/product_management/product_management_bloc.dart';

import 'package:app/config/router/app_router.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/pos/data/repositories/product_repository_impl.dart';
import 'package:app/features/pos/presentation/bloc/menu_bloc.dart';

void main() async {
  // 1. Inicialización del Motor
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicialización de la BD
  final db = AppDatabase();
  await db.seedInitialData();

  runApp(MainApp(db: db));
}

class MainApp extends StatelessWidget {
  final AppDatabase db;

  const MainApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiRepositoryProvider para inyectar ambos repos
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ProductRepositoryImpl(db)),
        RepositoryProvider(create: (context) => AuthRepositoryImpl(db)),
        RepositoryProvider(create: (context) => InventoryRepositoryImpl(db)),
        // CORRECCIÓN: Agregar SalesRepository aquí
        RepositoryProvider(create: (context) => SalesRepositoryImpl(db)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                MenuBloc(context.read<ProductRepositoryImpl>(),
                        db)
                  ..add(LoadProducts()),
          ),
          BlocProvider(
            create: (context) =>
                AuthBloc(context.read<AuthRepositoryImpl>()), // <--- NUEVO
          ),
          BlocProvider(
            create: (context) => InventoryBloc(
              context.read<InventoryRepositoryImpl>()
              )..add(SubscribeToInventory()),
          ),
          BlocProvider(
            create: (context) => TableBloc(db)..add(SubscribeToTables())
          ),
          BlocProvider(
            create: (context) => SalesBloc(
              context.read<SalesRepositoryImpl>(),
            )..add(LoadSalesHistory()), // Cargar historial al iniciar (o puedes cargarlo lazy)
          ),
          BlocProvider(create: (context) => ProductManagementBloc(
            context.read<ProductRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false, // Opcional: Quitar listón debug
        ),
      ),
    );
  }
}