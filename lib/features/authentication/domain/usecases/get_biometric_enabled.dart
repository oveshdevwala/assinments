import '../repositories/auth_repository.dart';

/// Use case for checking if biometric authentication is enabled
class GetBiometricEnabled {
  final AuthRepository _repository;

  const GetBiometricEnabled(this._repository);

  /// Execute biometric enabled check
  Future<bool> call() async {
    return await _repository.isBiometricEnabled();
  }
}
