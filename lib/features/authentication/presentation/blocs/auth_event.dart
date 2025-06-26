/// Base class for authentication events
abstract class AuthEvent {
  const AuthEvent();
}

/// Event to check biometric availability
class CheckBiometricAvailabilityEvent extends AuthEvent {
  const CheckBiometricAvailabilityEvent();
}

/// Event to authenticate with biometrics
class AuthenticateWithBiometricsEvent extends AuthEvent {
  final String reason;
  final bool useErrorDialogs;
  final bool stickyAuth;

  const AuthenticateWithBiometricsEvent({
    required this.reason,
    this.useErrorDialogs = true,
    this.stickyAuth = false,
  });
}

/// Event to set up PIN
class SetPinEvent extends AuthEvent {
  final String pin;
  final String confirmPin;

  const SetPinEvent({required this.pin, required this.confirmPin});
}

/// Event to verify PIN
class VerifyPinEvent extends AuthEvent {
  final String pin;

  const VerifyPinEvent({required this.pin});
}

/// Event to enable/disable biometric authentication
class ToggleBiometricEvent extends AuthEvent {
  final bool enable;

  const ToggleBiometricEvent({required this.enable});
}

/// Event to check if biometric authentication is enabled
class CheckBiometricEnabledEvent extends AuthEvent {
  const CheckBiometricEnabledEvent();
}

/// Event to initialize app auth state
class InitializeAuthEvent extends AuthEvent {
  const InitializeAuthEvent();
}

/// Event to logout user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event to clear all stored data
class ClearAllDataEvent extends AuthEvent {
  const ClearAllDataEvent();
}
