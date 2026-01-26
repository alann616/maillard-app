import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Imports de tu proyecto
import 'package:app/config/router/app_router.dart';
import 'package:app/features/pos/data/database/app_database.dart';
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
    // 3. INYECCIÓN DE DEPENDENCIAS GLOBAL
    // Todo lo que esté debajo de esto puede acceder a la BD y al Menú
    return RepositoryProvider(
      create: (context) => ProductRepositoryImpl(db),
      child: BlocProvider(
        // Inicializamos el BLoC aquí para que el menú cargue rápido
        // incluso antes de entrar a la pantalla
        create: (context) => MenuBloc(context.read<ProductRepositoryImpl>())
          ..add(LoadProducts()),
        child: MaterialApp.router(
          // 4. CONFIGURACIÓN DEL ROUTER (Escalabilidad)
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          title: 'Maillard POS',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueGrey,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}