import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/authenticate_with_biometrics.dart';
import '../../domain/usecases/check_biometric_availability.dart';
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
    required this.clearStoredCredentials,
    required this.getBiometricEnabled,
    required this.getStoredCredentials,
    required this.setBiometricEnabled,
    required this.setPin,
    required this.storeCredentials,
    required this.verifyPin,
  }) : super(const AuthState()) {
    on<InitializeAuthEvent>(_onInitializeAuth);
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricsEvent>(_onAuthenticateWithBiometrics);
    on<ToggleBiometricEvent>(_onToggleBiometric);
    on<LogoutEvent>(_onLogout);
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
      emit(state.copyWith(isLoading: true));

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
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Biometric authentication failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Biometric authentication error: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle app initialization
  Future<void> _onInitializeAuth(
    InitializeAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check biometric availability and enabled status
      final biometricInfo = await checkBiometricAvailability();
      final isBiometricEnabled = await getBiometricEnabled();

      emit(
        state.copyWith(
          biometricInfo: biometricInfo,
          canUseBiometric: biometricInfo.isAvailable,
          isBiometricEnabled: isBiometricEnabled,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to initialize authentication: ${e.toString()}',
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

      emit(state.copyWith(isBiometricEnabled: event.enable, isLoading: false));
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
