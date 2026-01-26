import '../../../../features/pos/data/database/app_database.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;
  AuthRepositoryImpl(this._db);

  @override
  Future<User?> loginWithPin(String pin) async {
    // Usamos el método getUserByPin que creamos en AppDatabase
    return _db.getUserByPin(pin);
  }
}