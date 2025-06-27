import '../../domain/entities/biometric_info.dart';
import '../../domain/entities/user_credentials.dart';

/// Authentication status enum
enum AuthenticationStatus { unknown, authenticated, unauthenticated }

/// Authentication flow state enum
enum AuthFlowState {
  initial,
  selectingMethod,
  authenticatingWithPin,
  authenticatingWithBiometric,
}

/// Authentication state
class AuthState {
  final AuthenticationStatus authenticationStatus;
  final AuthFlowState authFlowState;
  final UserCredentials? credentials;
  final BiometricInfo? biometricInfo;
  final bool isLoading;
  final String? error;
  final bool canUseBiometric;
  final bool hasStoredCredentials;
  final bool isPinSet;
  final bool isBiometricEnabled;

  const AuthState({
    this.authenticationStatus = AuthenticationStatus.unknown,
    this.authFlowState = AuthFlowState.initial,
    this.credentials,
    this.biometricInfo,
    this.isLoading = false,
    this.error,
    this.canUseBiometric = false,
    this.hasStoredCredentials = false,
    this.isPinSet = false,
    this.isBiometricEnabled = false,
  });

  /// Check if user is authenticated
  bool get isAuthenticated =>
      authenticationStatus == AuthenticationStatus.authenticated;

  /// Check if secure auth is fully setup (biometric + PIN)
  bool get isSecureAuthSetup =>
      canUseBiometric && isPinSet && hasStoredCredentials;

  /// Check if biometric authentication is required on app startup
  bool get requiresBiometricOnStartup => isBiometricEnabled && canUseBiometric;

  /// Check if we should show authentication options
  bool get shouldShowAuthOptions => isPinSet || isBiometricEnabled;

  /// Get user display name
  String get userDisplayName {
    if (credentials?.email != null) {
      return credentials!.email.split('@').first;
    }
    return 'User';
  }

  /// Create a copy of the state with updated values
  AuthState copyWith({
    AuthenticationStatus? authenticationStatus,
    AuthFlowState? authFlowState,
    UserCredentials? credentials,
    BiometricInfo? biometricInfo,
    bool? isLoading,
    String? error,
    bool? canUseBiometric,
    bool? hasStoredCredentials,
    bool? isPinSet,
    bool? isBiometricEnabled,
  }) {
    return AuthState(
      authenticationStatus: authenticationStatus ?? this.authenticationStatus,
      authFlowState: authFlowState ?? this.authFlowState,
      credentials: credentials ?? this.credentials,
      biometricInfo: biometricInfo ?? this.biometricInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      canUseBiometric: canUseBiometric ?? this.canUseBiometric,
      hasStoredCredentials: hasStoredCredentials ?? this.hasStoredCredentials,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }

  /// Create a copy without error
  AuthState clearError() {
    return copyWith(error: null);
  }

  /// Reset to initial state
  AuthState resetFlow() {
    return copyWith(
      authFlowState: AuthFlowState.initial,
      error: null,
      isLoading: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.authenticationStatus == authenticationStatus &&
        other.authFlowState == authFlowState &&
        other.credentials == credentials &&
        other.biometricInfo == biometricInfo &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.canUseBiometric == canUseBiometric &&
        other.hasStoredCredentials == hasStoredCredentials &&
        other.isPinSet == isPinSet &&
        other.isBiometricEnabled == isBiometricEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      authenticationStatus,
      authFlowState,
      credentials,
      biometricInfo,
      isLoading,
      error,
      canUseBiometric,
      hasStoredCredentials,
      isPinSet,
      isBiometricEnabled,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $authenticationStatus, flowState: $authFlowState, isLoading: $isLoading, hasCredentials: $hasStoredCredentials, canUseBiometric: $canUseBiometric, isPinSet: $isPinSet, isBiometricEnabled: $isBiometricEnabled)';
  }
}
