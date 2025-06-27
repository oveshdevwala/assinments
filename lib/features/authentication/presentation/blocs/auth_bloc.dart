import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/authenticate_with_biometrics.dart';
import '../../domain/usecases/check_biometric_availability.dart';
import '../../domain/usecases/check_pin_set.dart';
import '../../domain/usecases/clear_stored_credentials.dart';
import '../../domain/usecases/get_biometric_enabled.dart';
import '../../domain/usecases/get_stored_credentials.dart';
import '../../domain/usecases/set_biometric_enabled.dart';
import '../../domain/usecases/set_pin.dart';
import '../../domain/usecases/store_credentials.dart';
import '../../domain/usecases/verify_pin.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state and operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticateWithBiometrics authenticateWithBiometrics;
  final CheckBiometricAvailability checkBiometricAvailability;
  final CheckPinSet checkPinSet;
  final ClearStoredCredentials clearStoredCredentials;
  final GetBiometricEnabled getBiometricEnabled;
  final GetStoredCredentials getStoredCredentials;
  final SetBiometricEnabled setBiometricEnabled;
  final SetPin setPin;
  final StoreCredentials storeCredentials;
  final VerifyPin verifyPin;

  AuthBloc({
    required this.authenticateWithBiometrics,
    required this.checkBiometricAvailability,
    required this.checkPinSet,
    required this.clearStoredCredentials,
    required this.getBiometricEnabled,
    required this.getStoredCredentials,
    required this.setBiometricEnabled,
    required this.setPin,
    required this.storeCredentials,
    required this.verifyPin,
  }) : super(const AuthState()) {
    // Register all event handlers
    on<InitializeAuthEvent>(_onInitializeAuth);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricsEvent>(_onAuthenticateWithBiometrics);
    on<AuthenticateWithPinEvent>(_onAuthenticateWithPin);
    on<SetPinEvent>(_onSetPin);
    on<VerifyPinEvent>(_onVerifyPin);
    on<ToggleBiometricEvent>(_onToggleBiometric);
    on<SelectAuthMethodEvent>(_onSelectAuthMethod);
    on<ResetAuthFlowEvent>(_onResetAuthFlow);
    on<CheckPinSetEvent>(_onCheckPinSet);
    on<CompletePinSetupEvent>(_onCompletePinSetup);
    on<LogoutEvent>(_onLogout);
  }

  /// Handle app initialization
  Future<void> _onInitializeAuth(
    InitializeAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Check biometric availability and enabled status
      final biometricInfo = await checkBiometricAvailability();
      final isBiometricEnabled = await getBiometricEnabled();

      // Check if PIN is set directly
      final isPinSet = await checkPinSet();

      // Check if we have stored credentials
      final credentials = await getStoredCredentials();

      emit(
        state.copyWith(
          biometricInfo: biometricInfo,
          canUseBiometric: biometricInfo.isAvailable,
          isBiometricEnabled: isBiometricEnabled,
          isPinSet: isPinSet,
          hasStoredCredentials: credentials != null,
          isLoading: false,
          authFlowState: AuthFlowState.initial,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to initialize authentication: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle checking authentication status on app startup
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          authenticationStatus: AuthenticationStatus.unknown,
        ),
      );

      // Check biometric availability and enabled status
      final biometricInfo = await checkBiometricAvailability();
      final isBiometricEnabled = await getBiometricEnabled();

      // Check if PIN is set directly
      final isPinSet = await checkPinSet();

      // Check if we have stored credentials
      final credentials = await getStoredCredentials();

      // Determine authentication status based on setup
      AuthenticationStatus authStatus = AuthenticationStatus.unauthenticated;

      // If no PIN is set, user needs to set up authentication
      if (!isPinSet) {
        authStatus = AuthenticationStatus.unauthenticated;
      } else {
        // PIN is set, user needs to authenticate
        authStatus = AuthenticationStatus.unauthenticated;
      }

      emit(
        state.copyWith(
          biometricInfo: biometricInfo,
          canUseBiometric: biometricInfo.isAvailable,
          isBiometricEnabled: isBiometricEnabled,
          isPinSet: isPinSet,
          hasStoredCredentials: credentials != null,
          authenticationStatus: authStatus,
          isLoading: false,
          authFlowState: AuthFlowState.initial,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          authenticationStatus: AuthenticationStatus.unauthenticated,
          error: 'Failed to check authentication status: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle checking biometric availability
  Future<void> _onCheckBiometricAvailability(
    CheckBiometricAvailabilityEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final biometricInfo = await checkBiometricAvailability();

      emit(
        state.copyWith(
          biometricInfo: biometricInfo,
          canUseBiometric: biometricInfo.isAvailable,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to check biometric availability: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle biometric authentication
  Future<void> _onAuthenticateWithBiometrics(
    AuthenticateWithBiometricsEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          authFlowState: AuthFlowState.authenticatingWithBiometric,
        ),
      );

      final isAuthenticated = await authenticateWithBiometrics(
        reason: event.reason,
        useErrorDialogs: event.useErrorDialogs,
        stickyAuth: event.stickyAuth,
      );

      if (isAuthenticated) {
        emit(
          state.copyWith(
            authenticationStatus: AuthenticationStatus.authenticated,
            isLoading: false,
            error: null,
            authFlowState: AuthFlowState.initial,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Biometric authentication failed',
            authFlowState: AuthFlowState.initial,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Biometric authentication error: ${e.toString()}',
          authFlowState: AuthFlowState.initial,
        ),
      );
    }
  }

  /// Handle PIN authentication
  Future<void> _onAuthenticateWithPin(
    AuthenticateWithPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          error: null, // Clear previous errors
        ),
      );

      final isValid = await verifyPin(event.pin);

      if (isValid) {
        emit(
          state.copyWith(
            authenticationStatus: AuthenticationStatus.authenticated,
            isLoading: false,
            error: null,
            authFlowState: AuthFlowState.initial,
          ),
        );
      } else {
        emit(
          state.copyWith(
            authenticationStatus: AuthenticationStatus.unauthenticated,
            isLoading: false,
            error: 'Wrong PIN. Please try again.',
            authFlowState: AuthFlowState.initial,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          authenticationStatus: AuthenticationStatus.unauthenticated,
          isLoading: false,
          error: 'Authentication failed. Please try again.',
          authFlowState: AuthFlowState.initial,
        ),
      );
    }
  }

  /// Handle PIN setup
  Future<void> _onSetPin(SetPinEvent event, Emitter<AuthState> emit) async {
    try {
      // Validate PIN format
      if (event.pin.length != 4) {
        emit(state.copyWith(error: 'PIN must be exactly 4 digits'));
        return;
      }

      if (!RegExp(r'^\d{4}$').hasMatch(event.pin)) {
        emit(state.copyWith(error: 'PIN must contain only numbers'));
        return;
      }

      if (event.pin != event.confirmPin) {
        emit(state.copyWith(error: 'PIN confirmation does not match'));
        return;
      }

      emit(state.copyWith(isLoading: true));

      // Set the PIN
      await setPin(event.pin);

      emit(
        state.copyWith(
          isLoading: false,
          isPinSet: true,
          hasStoredCredentials: true,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to set PIN: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle PIN verification
  Future<void> _onVerifyPin(
    VerifyPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final isValid = await verifyPin(event.pin);

      emit(
        state.copyWith(isLoading: false, error: isValid ? null : 'Invalid PIN'),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'PIN verification error: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle toggling biometric authentication
  Future<void> _onToggleBiometric(
    ToggleBiometricEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await setBiometricEnabled(event.enable);

      emit(
        state.copyWith(
          isBiometricEnabled: event.enable,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error:
              'Failed to ${event.enable ? 'enable' : 'disable'} biometric authentication: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle selecting authentication method
  void _onSelectAuthMethod(
    SelectAuthMethodEvent event,
    Emitter<AuthState> emit,
  ) {
    final newFlowState = event.method == AuthenticationMethod.biometric
        ? AuthFlowState.authenticatingWithBiometric
        : AuthFlowState.authenticatingWithPin;

    emit(state.copyWith(authFlowState: newFlowState, error: null));
  }

  /// Handle resetting authentication flow
  void _onResetAuthFlow(ResetAuthFlowEvent event, Emitter<AuthState> emit) {
    emit(state.resetFlow());
  }

  /// Handle checking if PIN is set
  Future<void> _onCheckPinSet(
    CheckPinSetEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final credentials = await getStoredCredentials();
      final isPinSet = credentials != null;

      emit(state.copyWith(isPinSet: isPinSet, hasStoredCredentials: isPinSet));
    } catch (e) {
      emit(
        state.copyWith(error: 'Failed to check PIN status: ${e.toString()}'),
      );
    }
  }

  /// Handle completing PIN setup (after validation)
  Future<void> _onCompletePinSetup(
    CompletePinSetupEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Set the PIN
      await setPin(event.pin);

      emit(
        state.copyWith(
          isLoading: false,
          isPinSet: true,
          hasStoredCredentials: true,
          error: null,
          authFlowState: AuthFlowState.initial,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to set PIN: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle logout/clear data
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      await clearStoredCredentials();

      emit(
        const AuthState(
          authenticationStatus: AuthenticationStatus.unauthenticated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Clear data failed: ${e.toString()}',
        ),
      );
    }
  }
}
