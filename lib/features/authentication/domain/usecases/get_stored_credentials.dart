import '../entities/user_credentials.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting stored user credentials
class GetStoredCredentials {
  final AuthRepository _repository;

  const GetStoredCredentials(this._repository);

  /// Execute credential retrieval
  Future<UserCredentials?> call() async {
    return await _repository.getStoredCredentials();
  }
}
