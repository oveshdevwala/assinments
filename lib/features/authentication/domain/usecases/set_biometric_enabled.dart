import '../repositories/auth_repository.dart';

/// Use case for enabling/disabling biometric authentication
class SetBiometricEnabled {
  final AuthRepository _repository;

  const SetBiometricEnabled(this._repository);

  /// Execute biometric enablement setting
  Future<void> call(bool enabled) async {
    return await _repository.setBiometricEnabled(enabled);
  }
}
