import '../entities/biometric_info.dart';
import '../entities/user_credentials.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Check if biometric authentication is available on device
  Future<BiometricInfo> checkBiometricAvailability();

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  });

  /// Store user credentials securely
  Future<void> storeCredentials(UserCredentials credentials);

  /// Get stored user credentials
  Future<UserCredentials?> getStoredCredentials();

  /// Clear all stored credentials
  Future<void> clearStoredCredentials();

  /// Set PIN for authentication
  Future<void> setPin(String pin);

  /// Verify PIN
  Future<bool> verifyPin(String pin);

  /// Check if PIN is set
  Future<bool> isPinSet();

  /// Clear PIN
  Future<void> clearPin();

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled);

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled();
}
