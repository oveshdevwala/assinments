/// User credentials entity representing authenticated user data
class UserCredentials {
  final String userId;
  final String email;
  final String? token;
  final bool biometricEnabled;
  final bool hasPinSetup;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const UserCredentials({
    required this.userId,
    required this.email,
    this.token,
    this.biometricEnabled = false,
    this.hasPinSetup = false,
    this.lastLoginAt,
    required this.createdAt,
  });

  /// Create a copy of credentials with updated values
  UserCredentials copyWith({
    String? userId,
    String? email,
    String? token,
    bool? biometricEnabled,
    bool? hasPinSetup,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return UserCredentials(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      token: token ?? this.token,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPinSetup: hasPinSetup ?? this.hasPinSetup,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserCredentials &&
        other.userId == userId &&
        other.email == email &&
        other.token == token &&
        other.biometricEnabled == biometricEnabled &&
        other.hasPinSetup == hasPinSetup &&
        other.lastLoginAt == lastLoginAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      email,
      token,
      biometricEnabled,
      hasPinSetup,
      lastLoginAt,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'UserCredentials(userId: $userId, email: $email, biometricEnabled: $biometricEnabled, hasPinSetup: $hasPinSetup)';
  }
}
