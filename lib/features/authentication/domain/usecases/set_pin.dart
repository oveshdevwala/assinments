import '../repositories/auth_repository.dart';

/// Use case for setting user PIN
class SetPin {
  final AuthRepository _repository;

  const SetPin(this._repository);

  /// Execute PIN setting
  Future<void> call(String pin) async {
    // Validate PIN format
    if (pin.length < 4) {
      throw ArgumentError('PIN must be at least 4 digits');
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain only digits');
    }

    return await _repository.setPin(pin);
  }
}
