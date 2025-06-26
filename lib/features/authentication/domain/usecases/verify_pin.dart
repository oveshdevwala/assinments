import '../repositories/auth_repository.dart';

/// Use case for verifying user PIN
class VerifyPin {
  final AuthRepository _repository;

  const VerifyPin(this._repository);

  /// Execute PIN verification
  Future<bool> call(String pin) async {
    // Basic validation
    if (pin.isEmpty) {
      return false;
    }

    return await _repository.verifyPin(pin);
  }
}
