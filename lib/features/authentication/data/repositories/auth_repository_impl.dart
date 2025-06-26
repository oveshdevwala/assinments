import '../../domain/entities/biometric_info.dart';
import '../../domain/entities/user_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_datasource.dart';
import '../datasources/secure_storage_datasource.dart';
import '../models/user_credentials_model.dart';

/// Implementation of AuthRepository using local data sources
class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageDataSource secureStorageDataSource;
  final LocalAuthDataSource localAuthDataSource;

  const AuthRepositoryImpl({
    required this.secureStorageDataSource,
    required this.localAuthDataSource,
  });

  @override
  Future<BiometricInfo> checkBiometricAvailability() async {
    return await localAuthDataSource.checkBiometricAvailability();
  }

  @override
  Future<bool> authenticateWithBiometrics({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    return await localAuthDataSource.authenticateWithBiometrics(
      reason: reason,
      useErrorDialogs: useErrorDialogs,
      stickyAuth: stickyAuth,
    );
  }

  @override
  Future<void> storeCredentials(UserCredentials credentials) async {
    final model = UserCredentialsModel.fromEntity(credentials);
    await secureStorageDataSource.storeCredentials(model);
  }

  @override
  Future<UserCredentials?> getStoredCredentials() async {
    final model = await secureStorageDataSource.getStoredCredentials();
    return model?.toEntity();
  }

  @override
  Future<void> clearStoredCredentials() async {
    await secureStorageDataSource.clearStoredCredentials();
  }

  @override
  Future<void> setPin(String pin) async {
    await secureStorageDataSource.storePin(pin);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    return await secureStorageDataSource.verifyPin(pin);
  }

  @override
  Future<bool> isPinSet() async {
    return await secureStorageDataSource.isPinSet();
  }

  @override
  Future<void> clearPin() async {
    await secureStorageDataSource.clearPin();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await secureStorageDataSource.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await secureStorageDataSource.isBiometricEnabled();
  }
}
