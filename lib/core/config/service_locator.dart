import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../features/authentication/data/datasources/local_auth_datasource.dart';
import '../../features/authentication/data/datasources/secure_storage_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/authenticate_with_biometrics.dart';
import '../../features/authentication/domain/usecases/check_biometric_availability.dart';
import '../../features/authentication/domain/usecases/clear_stored_credentials.dart';
import '../../features/authentication/domain/usecases/get_biometric_enabled.dart';
import '../../features/authentication/domain/usecases/get_stored_credentials.dart';
import '../../features/authentication/domain/usecases/set_biometric_enabled.dart';
import '../../features/authentication/domain/usecases/set_pin.dart';
import '../../features/authentication/domain/usecases/store_credentials.dart';
import '../../features/authentication/domain/usecases/verify_pin.dart';
import '../../features/authentication/presentation/blocs/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    // External dependencies - with safer configuration
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences:
              false, // Disable encryption for compatibility
        ),
        iOptions: IOSOptions(),
      ),
    );

    sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());

    // Data sources
    sl.registerLazySingleton<SecureStorageDataSource>(
      () => SecureStorageDataSourceImpl(sl()),
    );

    sl.registerLazySingleton<LocalAuthDataSource>(
      () => LocalAuthDataSourceImpl(sl()),
    );

    // Repository
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        secureStorageDataSource: sl(),
        localAuthDataSource: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => AuthenticateWithBiometrics(sl()));
    sl.registerLazySingleton(() => CheckBiometricAvailability(sl()));
    sl.registerLazySingleton(() => ClearStoredCredentials(sl()));
    sl.registerLazySingleton(() => GetBiometricEnabled(sl()));
    sl.registerLazySingleton(() => GetStoredCredentials(sl()));
    sl.registerLazySingleton(() => SetBiometricEnabled(sl()));
    sl.registerLazySingleton(() => SetPin(sl()));
    sl.registerLazySingleton(() => StoreCredentials(sl()));
    sl.registerLazySingleton(() => VerifyPin(sl()));

    // BLoC
    sl.registerFactory(
      () => AuthBloc(
        authenticateWithBiometrics: sl(),
        checkBiometricAvailability: sl(),
        clearStoredCredentials: sl(),
        getBiometricEnabled: sl(),
        getStoredCredentials: sl(),
        setBiometricEnabled: sl(),
        setPin: sl(),
        storeCredentials: sl(),
        verifyPin: sl(),
      ),
    );
  } catch (e) {
    print('Error during service locator initialization: $e');
    rethrow;
  }
}
