import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:app/features/pos/presentation/bloc/table_bloc.dart';
import 'package:app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ✅ CORREGIDO: Ahora usa package:app/...
import 'package:app/features/pos/presentation/bloc/product_management/product_management_bloc.dart';

import 'package:app/config/router/app_router.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/features/pos/data/repositories/product_repository_impl.dart';
import 'package:app/features/pos/presentation/bloc/menu_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await db.seedInitialData(); // Descomenta solo si necesitas resetear datos

  runApp(MainApp(db: db));
}

class MainApp extends StatelessWidget {
  final AppDatabase db;

  const MainApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => ProductRepositoryImpl(db)),
        RepositoryProvider(create: (context) => AuthRepositoryImpl(db)),
        RepositoryProvider(create: (context) => InventoryRepositoryImpl(db)),
        RepositoryProvider(create: (context) => SalesRepositoryImpl(db)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                MenuBloc(context.read<ProductRepositoryImpl>(), db)..add(LoadProducts()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepositoryImpl>()),
          ),
          BlocProvider(
            create: (context) => InventoryBloc(
                context.read<InventoryRepositoryImpl>())
              ..add(SubscribeToInventory()),
          ),
          BlocProvider(
            create: (context) => TableBloc(db)..add(SubscribeToTables()),
          ),
          BlocProvider(
            create: (context) => SalesBloc(
              context.read<SalesRepositoryImpl>(),
            )..add(SubscribeToSales()),
          ),
          BlocProvider(
            create: (context) => ProductManagementBloc(
              context.read<ProductRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}