import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// --- IMPORTS DE DOMINIO Y TABLAS ---
import '../../domain/models/product.dart';
import '../../../auth/data/database/users.dart'; // <--- Nueva tabla
import '../../../pos/domain/models/user_role.dart'; // <--- Enum

part 'app_database.g.dart';

@DriftDatabase(tables: [Products, Users]) // <--- Agregamos Users aquí
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 2; // <--- IMPORTANTE: Subimos versión

  // --- MIGRACIÓN (Para no perder datos al actualizar) ---
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll(); // Crea todo si es instalación limpia
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Si vienes de la versión 1, crea solo la tabla Users
          await m.createTable(users);
        }
      },
    );
  }

  // --- QUERIES ---
  Future<List<Product>> getAllProducts() => select(products).get();
  
  // Queries de Usuarios (Auth)
  Future<User?> getUserByPin(String pin) {
    return (select(users)..where((t) => t.pin.equals(pin))).getSingleOrNull();
  }

  // --- SEED (Datos Iniciales) ---
  Future<void> seedInitialData() async {
    // 1. Sembrar Productos (Lo que ya tenías)
    final productCount = await select(products).get().then((l) => l.length);
    if (productCount == 0) {
      await batch((batch) {
        batch.insertAll(products, [
          ProductsCompanion.insert(name: 'Espresso Doble', price: 45.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'Latte 10oz', price: 65.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'Flat White', price: 60.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'Cold Brew', price: 70.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'V60 Método', price: 80.0, category: 'Bebida'),
        ]);
      });
      print("🌱 SQLite: Menú sembrado.");
    }

    // 2. Sembrar Usuarios (NUEVO)
    final userCount = await select(users).get().then((l) => l.length);
    if (userCount == 0) {
      await batch((batch) {
        batch.insertAll(users, [
          // DUEÑO POR DEFECTO: PIN 1234
          UsersCompanion.insert(
            name: 'Administrador',
            pin: '1234',
            role: UserRole.admin,
          ),
          // EMPLEADO POR DEFECTO: PIN 0000
          UsersCompanion.insert(
            name: 'Mesero 1',
            pin: '0000',
            role: UserRole.employee,
          ),
        ]);
      });
      print("🌱 SQLite: Usuarios sembrados (Admin: 1234, Empleado: 0000).");
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'maillard.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}