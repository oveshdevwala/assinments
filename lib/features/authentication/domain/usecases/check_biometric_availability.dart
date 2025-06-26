import '../entities/biometric_info.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking biometric authentication availability
class CheckBiometricAvailability {
  final AuthRepository _repository;

  const CheckBiometricAvailability(this._repository);

  /// Execute biometric availability check
  Future<BiometricInfo> call() async {
    return await _repository.checkBiometricAvailability();
  }
}
