import '../repositories/auth_repository.dart';

/// Use case for clearing stored user credentials
class ClearStoredCredentials {
  final AuthRepository _repository;

  const ClearStoredCredentials(this._repository);

  /// Execute credential clearing
  Future<void> call() async {
    return await _repository.clearStoredCredentials();
  }
}
