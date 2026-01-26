import 'package:app/features/pos/domain/models/user_role.dart';
import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get pin => text()(); // Guardaremos el PIN como texto (ej: "1234")
  
  // Drift convierte automáticamente el Enum a entero (0 o 1) en la BD
  IntColumn get role => intEnum<UserRole>()();
}