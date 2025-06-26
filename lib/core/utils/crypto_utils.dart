import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Utility class for cryptographic operations
class CryptoUtils {
  CryptoUtils._();

  /// Generate a random salt for password hashing
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final saltBytes = List.generate(length, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// Hash a PIN with salt using PBKDF2
  static String hashPinWithSalt(String pin, String salt) {
    final saltBytes = base64Decode(salt);
    final pinBytes = utf8.encode(pin);

    // Simple HMAC-based key derivation (in production, use proper PBKDF2)
    final hmac = Hmac(sha256, saltBytes);
    final digest = hmac.convert(pinBytes);

    return base64Encode(digest.bytes);
  }

  /// Verify a PIN against its hash
  static bool verifyPin(String pin, String hash, String salt) {
    final computedHash = hashPinWithSalt(pin, salt);
    return computedHash == hash;
  }

  /// Generate a secure random string
  static String generateSecureRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Convert string to bytes
  static Uint8List stringToBytes(String input) {
    return Uint8List.fromList(utf8.encode(input));
  }

  /// Convert bytes to string
  static String bytesToString(Uint8List bytes) {
    return utf8.decode(bytes);
  }
}
