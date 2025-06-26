import 'package:local_auth/local_auth.dart';

/// Biometric information entity
class BiometricInfo {
  final bool isAvailable;
  final bool isDeviceSupported;
  final List<BiometricType> availableTypes;
  final String typesDescription;

  const BiometricInfo({
    required this.isAvailable,
    required this.isDeviceSupported,
    required this.availableTypes,
    required this.typesDescription,
  });

  /// Check if fingerprint is available
  bool get hasFingerprint => availableTypes.contains(BiometricType.fingerprint);

  /// Check if face recognition is available
  bool get hasFace => availableTypes.contains(BiometricType.face);

  /// Check if iris recognition is available
  bool get hasIris => availableTypes.contains(BiometricType.iris);

  /// Check if any strong biometric is available
  bool get hasStrongBiometric => availableTypes.contains(BiometricType.strong);

  /// Check if weak biometric is available
  bool get hasWeakBiometric => availableTypes.contains(BiometricType.weak);

  /// Get primary biometric type for display
  BiometricType? get primaryType {
    if (hasFingerprint) return BiometricType.fingerprint;
    if (hasFace) return BiometricType.face;
    if (hasIris) return BiometricType.iris;
    if (hasStrongBiometric) return BiometricType.strong;
    if (hasWeakBiometric) return BiometricType.weak;
    return null;
  }

  /// Get display name for primary biometric type
  String get primaryTypeName {
    switch (primaryType) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      case null:
        return 'None';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BiometricInfo &&
        other.isAvailable == isAvailable &&
        other.isDeviceSupported == isDeviceSupported &&
        other.availableTypes.length == availableTypes.length &&
        other.availableTypes.every((type) => availableTypes.contains(type)) &&
        other.typesDescription == typesDescription;
  }

  @override
  int get hashCode {
    return Object.hash(
      isAvailable,
      isDeviceSupported,
      availableTypes,
      typesDescription,
    );
  }

  @override
  String toString() {
    return 'BiometricInfo(isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported, types: $availableTypes)';
  }
}
