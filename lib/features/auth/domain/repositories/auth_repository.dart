import '../../../../features/pos/data/database/app_database.dart';

abstract class AuthRepository {
  Future<User?> loginWithPin(String pin);
}