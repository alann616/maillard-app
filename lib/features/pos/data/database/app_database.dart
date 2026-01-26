import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// CORRECCIÓN 1: Importar la tabla desde la carpeta domain
import '../../domain/models/product.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Products])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Product>> getAllProducts() => select(products).get();

  Future<void> seedInitialData() async {
    final count = await select(products).get().then((l) => l.length);
    if (count == 0) {
      await batch((batch) {
        batch.insertAll(products, [
          ProductsCompanion.insert(name: 'Espresso Doble', price: 45.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'Latte 10oz', price: 65.0, category: 'Bebida'),
          ProductsCompanion.insert(name: 'Flat White', price: 60.0, category: 'Bebida'),
        ]);
      });
      print("🌱 SQLite: Datos sembrados correctamente.");
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