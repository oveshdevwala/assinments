import '../repositories/auth_repository.dart';

/// Use case for checking if a PIN is set
class CheckPinSet {
  final AuthRepository repository;

  const CheckPinSet(this.repository);

  /// Check if a PIN is currently set
  Future<bool> call() async {
    return await repository.isPinSet();
  }
}
