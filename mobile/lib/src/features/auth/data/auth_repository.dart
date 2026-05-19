import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_base_url.dart';
import '../../../core/auth/auth_session_snapshot.dart';
import '../../../core/auth/phone_normalizer.dart';
import '../../../core/auth/token_persistence.dart';
import '../../../shared/contracts/login_credentials.dart';
import '../../../shared/contracts/login_result.dart';
import 'auth_api.dart';

/// Coordinates JWT auth against the Kech Django API + local session persistence.
final class AuthRepository {
  AuthRepository({
    required String baseUrl,
    AuthApi? api,
    TokenPersistence? persistence,
    http.Client? httpClient,
  }) : _api = api ?? AuthApi(baseUrl: baseUrl, httpClient: httpClient),
        _persistence = persistence ?? SecureTokenPersistence();

  final AuthApi _api;
  final TokenPersistence _persistence;

  AuthSessionSnapshot? _memorySession;

  AuthSessionSnapshot? get currentSession => _memorySession;

  Future<Map<String, dynamic>?> fetchMe({required String accessToken}) async {
    final http.Response response = await _api.me(accessToken: accessToken);
    if (response.statusCode != 200) {
      return null;
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> restoreSession() async {
    final snap = await _persistence.load();

    // Production-grade safety: only keep a restored session if the API still accepts it.
    // This prevents "stale token" boots that skip role selection but fail later.
    if (snap != null) {
      try {
        final http.Response me = await _api.me(accessToken: snap.accessToken);
        if (me.statusCode == 200) {
          _memorySession = snap;
          return;
        }
      } on Object catch (_) {
        // Network errors should not trap the user in a broken "authenticated" state.
        // Fall through to clearing session.
      }

      await _persistence.clear();
    }

    _memorySession = null;
  }

  Future<LoginResult> signIn({
    required LoginCredentials credentials,
    required String expectedApiRole,
  }) async {
    late final String phone;
    try {
      phone = PhoneNormalizer.toE164(credentials.identifier);
    } on FormatException catch (e) {
      return LoginFailure(e.message);
    }

    try {
      final response = await _api.obtainToken(phone: phone, password: credentials.password);
      if (response.statusCode != 200) {
        return LoginFailure(_mapLoginHttpFailure(expectedApiRole, response.body, response.statusCode));
      }

      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final String? access = body['access'] as String?;
      final String? refresh = body['refresh'] as String?;
      final String? role = body['role'] as String?;
      final int? userId = (body['user_id'] as num?)?.toInt();

      if (access == null || refresh == null || role == null || userId == null) {
        return const LoginFailure('Unexpected server response. Try again later.');
      }

      if (role != expectedApiRole) {
        return LoginFailure(
          'This phone is registered as ${_humanRole(role)}. Use the other app entry.',
        );
      }

      final AuthSessionSnapshot snapshot = AuthSessionSnapshot(
        accessToken: access,
        refreshToken: refresh,
        role: role,
        userId: userId,
      );
      await _persistence.save(snapshot);
      _memorySession = snapshot;

      final http.Response me = await _api.me(accessToken: access);
      if (me.statusCode != 200) {
        await signOut();
        return const LoginFailure('Could not verify your session. Try again.');
      }

      return const LoginSuccess();
    } on SocketException catch (_) {
      return LoginFailure(_networkHint());
    } on HttpException catch (_) {
      return LoginFailure(_networkHint());
    } on FormatException catch (_) {
      return const LoginFailure('Unexpected server response.');
    } on Object catch (e, st) {
      debugPrint('signIn error: $e\n$st');
      return const LoginFailure('Something went wrong. Please try again.');
    }
  }

  Future<LoginResult> registerCustomerAndSignIn({
    required String fullName,
    required String phoneRaw,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      return const LoginFailure('Passwords do not match.');
    }
    late final String phone;
    try {
      phone = PhoneNormalizer.toE164(phoneRaw);
    } on FormatException catch (e) {
      return LoginFailure(e.message);
    }

    try {
      final http.Response reg = await _api.registerCustomer(
        phone: phone,
        password: password,
        name: fullName.trim(),
      );
      if (reg.statusCode != 201) {
        return LoginFailure(_readDetail(reg.body) ?? 'Registration failed.');
      }

      return signIn(
        credentials: LoginCredentials(identifier: phone, password: password),
        expectedApiRole: 'customer',
      );
    } on SocketException catch (_) {
      return LoginFailure(_networkHint());
    } on Object catch (e, st) {
      debugPrint('registerCustomerAndSignIn: $e\n$st');
      return const LoginFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut() async {
    final AuthSessionSnapshot? snap = _memorySession ?? await _persistence.load();
    if (snap != null) {
      try {
        await _api.logout(accessToken: snap.accessToken, refreshToken: snap.refreshToken);
      } on Object catch (e, st) {
        debugPrint('logout best-effort failed: $e\n$st');
      }
    }
    await _persistence.clear();
    _memorySession = null;
  }

  static String _networkHint() {
    return 'Cannot reach the server at ${ApiBaseUrl.resolve()}. '
        'Ensure Django is running and reachable (Docker: port 8000 published).';
  }

  static String _mapLoginHttpFailure(String expectedRole, String body, int status) {
    final String? detail = _readDetail(body);
    if (RoleHelper.fromString(expectedRole) == Role.driver) {
      return detail ??
          'Sign-in failed. If you just registered, your driver account may still be pending approval.';
    }
    return detail ?? 'Sign-in failed (HTTP $status).';
  }

  static String? _readDetail(String body) {
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        // Try to get the 'detail' field first (generic errors)
        if (decoded['detail'] is String) {
          return decoded['detail'] as String;
        }
        // If no 'detail', try to extract the first field error (field-level validation)
        for (final entry in decoded.entries) {
          if (entry.key != 'detail') {
            final value = entry.value;
            // Handle list of error messages: {"password": ["error1", "error2"]}
            if (value is List && value.isNotEmpty && value.first is String) {
              return '${entry.key}: ${value.first}';
            }
            // Handle single error message: {"field": "error"}
            if (value is String) {
              return '${entry.key}: $value';
            }
          }
        }
      }
    } on Object catch (_) {
      /* ignore */
    }
    return null;
  }

  static String _humanRole(String apiRole) {
    switch (apiRole) {
      case 'customer':
        return 'a customer';
      case 'driver':
        return 'a driver';
      case 'admin':
        return 'an admin';
      case 'sales':
        return 'a sales agent';
      default:
        return apiRole;
    }
  }
}
