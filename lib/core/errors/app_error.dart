/// Base class for all application errors
abstract class AppError {
  final String message;
  final String? code;

  const AppError(this.message, {this.code});

  @override
  String toString() =>
      'AppError: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication related errors
class AuthError extends AppError {
  const AuthError(super.message, {super.code});
}

/// Biometric authentication errors
class BiometricError extends AuthError {
  const BiometricError(super.message, {super.code});
}

/// Storage related errors
class StorageError extends AppError {
  const StorageError(super.message, {super.code});
}

/// Network related errors
class NetworkError extends AppError {
  const NetworkError(super.message, {super.code});
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError(super.message, {super.code});
}

/// Generic errors
class GenericError extends AppError {
  const GenericError(super.message, {super.code});
}
