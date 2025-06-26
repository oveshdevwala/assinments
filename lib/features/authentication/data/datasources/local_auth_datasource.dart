import 'package:local_auth/local_auth.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/entities/biometric_info.dart';

/// Abstract datasource for local authentication operations
abstract class LocalAuthDataSource {
  Future<BiometricInfo> checkBiometricAvailability();
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  });
}

/// Implementation of local authentication using LocalAuthentication plugin
class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final LocalAuthentication _localAuth;

  const LocalAuthDataSourceImpl(this._localAuth);

  @override
  Future<BiometricInfo> checkBiometricAvailability() async {
    try {
      // Check if device supports biometrics
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      // Check if biometrics are available
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      // Create types description
      final typesDescription = _createTypesDescription(availableBiometrics);

      return BiometricInfo(
        isAvailable: canCheckBiometrics && availableBiometrics.isNotEmpty,
        isDeviceSupported: isDeviceSupported,
        availableTypes: availableBiometrics,
        typesDescription: typesDescription,
        
      );
    } catch (e) {
      // Return a default BiometricInfo with error handling
      return BiometricInfo(
        isAvailable: false,
        isDeviceSupported: false,
        availableTypes: const [],
        typesDescription: 'Error checking biometrics: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      // Simple authentication with minimal options to avoid configuration issues
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: false,
          biometricOnly: true, // Only use biometrics, avoid PIN fallback issues
        ),
      );

      return isAuthenticated;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      // Handle specific authentication exceptions
      if (errorMessage.contains('usercancel') ||
          errorMessage.contains('cancelled') ||
          errorMessage.contains('cancel')) {
        return false; // User cancelled, not an error
      } else {
        // For any other error, throw a generic biometric error
        throw BiometricError(
          'Biometric authentication is not available. Please ensure:\n\n'
          '1. Your device supports fingerprint/face authentication\n'
          '2. You have set up biometric authentication in Settings\n'
          '3. The biometric feature is enabled for this app\n\n'
          'Error details: ${_getReadableError(e.toString())}',
        );
      }
    }
  }

  /// Create a human-readable description of available biometric types
  String _createTypesDescription(List<BiometricType> types) {
    if (types.isEmpty) {
      return 'None available';
    }

    final typeNames = types.map((type) {
      switch (type) {
        case BiometricType.face:
          return 'Face ID';
        case BiometricType.fingerprint:
          return 'Fingerprint';
        case BiometricType.iris:
          return 'Iris';
        case BiometricType.strong:
          return 'Strong Biometric';
        case BiometricType.weak:
          return 'Weak Biometric';
      }
    }).toList();

    if (typeNames.length == 1) {
      return typeNames.first;
    } else if (typeNames.length == 2) {
      return '${typeNames[0]} and ${typeNames[1]}';
    } else {
      final lastType = typeNames.removeLast();
      return '${typeNames.join(', ')}, and $lastType';
    }
  }

  /// Convert technical error messages to user-friendly ones
  String _getReadableError(String error) {
    if (error.contains('PlatformException')) {
      return 'Device configuration issue. Try restarting the app.';
    } else if (error.contains('MissingPluginException')) {
      return 'Biometric feature not properly configured.';
    } else if (error.contains('NotAvailable')) {
      return 'Biometric authentication not available on this device.';
    } else if (error.contains('NotEnrolled')) {
      return 'No biometrics enrolled. Please set up in device Settings.';
    } else {
      return 'Unknown error occurred.';
    }
  }
}
