import 'package:drift/drift.dart';
// Importamos Products para poder relacionar la Receta con el Producto
import '../../../../features/pos/domain/models/product.dart';

// 1. INGREDIENTES (La Materia Prima)
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // Ej: "Café en Grano Chiapas"
  TextColumn get unit => text()(); // Ej: "g", "ml", "pz"
  RealColumn get currentStock => real()(); // Ej: 5000.0 (5kg)
  RealColumn get minStock => real().withDefault(const Constant(0.0))(); // Alerta de stock bajo
  RealColumn get costPerUnit => real()(); // Ej: $0.35 por gramo (Para costeo exacto)

  TextColumn get purchaseUnit => text().nullable()(); // Ej: "Botella", "Caja", "Bolsa"
  RealColumn get packageSize => real().nullable()(); // Ej: 750.0 (ml), 12.0 (pz)
}

// 2. RECETAS (La Fórmula Mágica)
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Relación: Un Ingrediente pertenece a un Producto
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get ingredientId => integer().references(Ingredients, #id)();
  
  // Cantidad necesaria para 1 unidad del producto
  RealColumn get quantityRequired => real()(); // Ej: 18.0 (gramos)
}