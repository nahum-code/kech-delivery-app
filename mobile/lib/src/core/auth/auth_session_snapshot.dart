import 'package:flutter/foundation.dart';

@immutable
class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String role;
  final int userId;

  /// Parsed role as a typed enum for safe comparisons.
  Role get roleEnum => RoleHelper.fromString(role);

  Map<String, Object?> toJson() => <String, Object?>{
        'access': accessToken,
        'refresh': refreshToken,
        'role': role,
        'user_id': userId,
      };

  static AuthSessionSnapshot fromJson(Map<String, dynamic> json) {
    return AuthSessionSnapshot(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
      role: json['role'] as String,
      userId: (json['user_id'] as num).toInt(),
    );
  }
}

/// Canonical application roles used throughout the app.
enum Role { customer, driver, admin, sales, unknown }

/// Small helper to convert persisted role strings to the [Role] enum.
class RoleHelper {
  static Role fromString(String? value) {
    switch (value) {
      case 'customer':
        return Role.customer;
      case 'driver':
        return Role.driver;
      case 'admin':
        return Role.admin;
      case 'sales':
        return Role.sales;
      default:
        return Role.unknown;
    }
  }
}
