import '../entities/user_credentials.dart';
import '../repositories/auth_repository.dart';

/// Use case for storing user credentials securely
class StoreCredentials {
  final AuthRepository _repository;

  const StoreCredentials(this._repository);

  /// Execute credential storage
  Future<void> call(UserCredentials credentials) async {
    return await _repository.storeCredentials(credentials);
  }
}
