import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../models/user_credentials_model.dart';

/// Abstract datasource for secure storage operations
abstract class SecureStorageDataSource {
  Future<void> storeCredentials(UserCredentialsModel credentials);
  Future<UserCredentialsModel?> getStoredCredentials();
  Future<void> clearStoredCredentials();
  Future<void> storePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> isPinSet();
  Future<void> clearPin();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
}

/// Implementation of secure storage using FlutterSecureStorage
class SecureStorageDataSourceImpl implements SecureStorageDataSource {
  final FlutterSecureStorage _storage;

  static const String _credentialsKey = 'user_credentials';
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _biometricEnabledKey = 'biometric_enabled';

  const SecureStorageDataSourceImpl(this._storage);

  @override
  Future<void> storeCredentials(UserCredentialsModel credentials) async {
    try {
      final jsonString = credentials.toJsonString();
      await _storage.write(key: _credentialsKey, value: jsonString);
    } catch (e) {
      throw StorageError('Failed to store credentials: $e');
    }
  }

  @override
  Future<UserCredentialsModel?> getStoredCredentials() async {
    try {
      final jsonString = await _storage.read(key: _credentialsKey);
      if (jsonString == null) return null;

      final model = UserCredentialsModel.fromJsonString(jsonString);

      // Convert model to domain entity
      return model;
    } catch (e) {
      // If there's an error reading/parsing, clear corrupted data
      await clearStoredCredentials();
      throw StorageError('Failed to get stored credentials: $e');
    }
  }

  @override
  Future<void> clearStoredCredentials() async {
    try {
      await _storage.delete(key: _credentialsKey);
    } catch (e) {
      throw StorageError('Failed to clear credentials: $e');
    }
  }

  @override
  Future<void> storePin(String pin) async {
    try {
      // Generate salt and hash the PIN
      final salt = CryptoUtils.generateSalt();
      final hash = CryptoUtils.hashPinWithSalt(pin, salt);

      // Store both hash and salt
      await Future.wait([
        _storage.write(key: _pinHashKey, value: hash),
        _storage.write(key: _pinSaltKey, value: salt),
      ]);
    } catch (e) {
      throw StorageError('Failed to store PIN: $e');
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final hash = await _storage.read(key: _pinHashKey);
      final salt = await _storage.read(key: _pinSaltKey);

      if (hash == null || salt == null) {
        return false;
      }

      return CryptoUtils.verifyPin(pin, hash, salt);
    } catch (e) {
      throw StorageError('Failed to verify PIN: $e');
    }
  }

  @override
  Future<bool> isPinSet() async {
    try {
      final hash = await _storage.read(key: _pinHashKey);
      return hash != null;
    } catch (e) {
      throw StorageError('Failed to check PIN status: $e');
    }
  }

  @override
  Future<void> clearPin() async {
    try {
      await Future.wait([
        _storage.delete(key: _pinHashKey),
        _storage.delete(key: _pinSaltKey),
      ]);
    } catch (e) {
      throw StorageError('Failed to clear PIN: $e');
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      throw StorageError('Failed to set biometric enabled: $e');
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      throw StorageError('Failed to check biometric enabled: $e');
    }
  }
}
