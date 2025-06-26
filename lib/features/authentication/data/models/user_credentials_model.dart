import 'dart:convert';
import '../../domain/entities/user_credentials.dart';

/// Data model for user credentials with JSON serialization
class UserCredentialsModel extends UserCredentials {
  const UserCredentialsModel({
    required super.userId,
    required super.email,
    super.token,
    super.biometricEnabled,
    super.hasPinSetup,
    super.lastLoginAt,
    required super.createdAt,
  });

  /// Create from domain entity
  factory UserCredentialsModel.fromEntity(UserCredentials credentials) {
    return UserCredentialsModel(
      userId: credentials.userId,
      email: credentials.email,
      token: credentials.token,
      biometricEnabled: credentials.biometricEnabled,
      hasPinSetup: credentials.hasPinSetup,
      lastLoginAt: credentials.lastLoginAt,
      createdAt: credentials.createdAt,
    );
  }

  /// Convert to domain entity
  UserCredentials toEntity() {
    return UserCredentials(
      userId: userId,
      email: email,
      token: token,
      biometricEnabled: biometricEnabled,
      hasPinSetup: hasPinSetup,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
    );
  }

  /// Create from JSON map
  factory UserCredentialsModel.fromJson(Map<String, dynamic> json) {
    return UserCredentialsModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      hasPinSetup: json['hasPinSetup'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'token': token,
      'biometricEnabled': biometricEnabled,
      'hasPinSetup': hasPinSetup,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON string
  factory UserCredentialsModel.fromJsonString(String jsonString) {
    return UserCredentialsModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create copy with updated values
  @override
  UserCredentialsModel copyWith({
    String? userId,
    String? email,
    String? token,
    bool? biometricEnabled,
    bool? hasPinSetup,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return UserCredentialsModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      token: token ?? this.token,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPinSetup: hasPinSetup ?? this.hasPinSetup,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
