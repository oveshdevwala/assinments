import '../repositories/auth_repository.dart';

/// Use case for authenticating user with biometrics
class AuthenticateWithBiometrics {
  final AuthRepository _repository;

  const AuthenticateWithBiometrics(this._repository);

  /// Execute biometric authentication
  Future<bool> call({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    return await _repository.authenticateWithBiometrics(
      reason: reason,
      useErrorDialogs: useErrorDialogs,
      stickyAuth: stickyAuth,
    );
  }
}
