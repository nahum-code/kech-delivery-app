import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/driver_onboarding_storage.dart';
import '../../../core/auth/phone_normalizer.dart';
import '../../../shared/contracts/login_result.dart';
import 'driver_onboarding_api.dart';
import 'models/driver_status.dart';

/// Driver onboarding orchestration (register → documents → OTP → pending).
final class DriverOnboardingRepository {
  DriverOnboardingRepository({
    required DriverOnboardingApi api,
    DriverOnboardingStorage? storage,
  })  : _api = api,
        _storage = storage ?? DriverOnboardingStorage();

  final DriverOnboardingApi _api;
  final DriverOnboardingStorage _storage;

  DriverOnboardingSnapshot? _memoryOnboarding;

  DriverOnboardingSnapshot? get currentOnboarding => _memoryOnboarding;

  Future<void> restoreOnboarding() async {
    _memoryOnboarding = await _storage.load();
  }

  Future<LoginResult> registerDriver({
    required String fullName,
    required String email,
    required String phoneRaw,
    required String password,
    required String confirmPassword,
    required String vehicleType,
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
      final http.Response res = await _api.registerDriver(
        phone: phone,
        password: password,
        name: fullName.trim(),
        email: email.trim(),
        vehicleType: vehicleType,
      );
      if (res.statusCode != 201) {
        return LoginFailure(_readError(res.body) ?? 'Registration failed.');
      }

      final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
      final String? token = body['registration_token'] as String?;
      final int? userId = (body['id'] as num?)?.toInt();
      if (token == null || userId == null) {
        return const LoginFailure('Unexpected server response.');
      }

      final DriverOnboardingSnapshot snap = DriverOnboardingSnapshot(
        userId: userId,
        phone: phone,
        registrationToken: token,
        approvalStatus: body['approval_status'] as String? ?? 'pending',
      );
      await _storage.save(snap);
      _memoryOnboarding = snap;
      return const LoginSuccess();
    } on SocketException catch (_) {
      return LoginFailure(_networkHint());
    } on Object catch (e, st) {
      debugPrint('registerDriver: $e\n$st');
      return const LoginFailure('Something went wrong. Please try again.');
    }
  }

  Future<LoginResult> uploadDocument({
    required String documentType,
    required String filePath,
    required String filename,
    String? contentType,
  }) async {
    final DriverOnboardingSnapshot? snap = _memoryOnboarding ?? await _storage.load();
    if (snap == null) {
      return const LoginFailure('Onboarding session expired. Please register again.');
    }

    try {
      final http.StreamedResponse streamed = await _api.uploadDocument(
        registrationToken: snap.registrationToken,
        documentType: documentType,
        filePath: filePath,
        filename: filename,
        contentType: contentType,
      );
      final http.Response res = await http.Response.fromStream(streamed);
      if (res.statusCode != 201) {
        return LoginFailure(_readError(res.body) ?? 'Upload failed.');
      }
      return const LoginSuccess();
    } on SocketException catch (_) {
      return LoginFailure(_networkHint());
    } on Object catch (e, st) {
      debugPrint('uploadDocument: $e\n$st');
      return const LoginFailure('Upload failed. Please try again.');
    }
  }

  Future<LoginResult> sendOtp() async {
    final DriverOnboardingSnapshot? snap = _memoryOnboarding ?? await _storage.load();
    if (snap == null) {
      return const LoginFailure('Onboarding session expired.');
    }
    try {
      final http.Response res = await _api.sendOtp(
        registrationToken: snap.registrationToken,
        phone: snap.phone,
      );
      if (res.statusCode != 200) {
        return LoginFailure(_readError(res.body) ?? 'Could not send code.');
      }
      return const LoginSuccess();
    } on SocketException catch (_) {
      return LoginFailure(_networkHint());
    } on Object catch (_) {
      return const LoginFailure('Could not send verification code.');
    }
  }

  Future<LoginResult> verifyOtp(String code) async {
    final DriverOnboardingSnapshot? snap = _memoryOnboarding ?? await _storage.load();
    if (snap == null) {
      return const LoginFailure('Onboarding session expired.');
    }
    try {
      final http.Response res = await _api.verifyOtp(
        registrationToken: snap.registrationToken,
        phone: snap.phone,
        code: code.trim(),
      );
      if (res.statusCode != 200) {
        return LoginFailure(_readError(res.body) ?? 'Invalid verification code.');
      }
      return const LoginSuccess();
    } on SocketException catch (_) {
      return LoginFailure(_networkHint());
    } on Object catch (_) {
      return const LoginFailure('Verification failed.');
    }
  }

  Future<DriverStatus?> fetchOnboardingStatus() async {
    final DriverOnboardingSnapshot? snap = _memoryOnboarding ?? await _storage.load();
    if (snap == null) {
      return null;
    }
    try {
      final http.Response res = await _api.fetchOnboardingStatus(
        registrationToken: snap.registrationToken,
      );
      if (res.statusCode != 200) {
        return null;
      }
      final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
      final DriverStatus status = DriverStatus.fromJson(body);
      _memoryOnboarding = snap.copyWith(approvalStatus: status.approvalStatus);
      await _storage.save(_memoryOnboarding!);
      return status;
    } on Object catch (e, st) {
      debugPrint('fetchOnboardingStatus: $e\n$st');
      return null;
    }
  }

  Future<void> clearOnboarding() async {
    await _storage.clear();
    _memoryOnboarding = null;
  }

  static String _networkHint() {
    return 'Cannot reach the server. Check your connection and API_BASE_URL.';
  }

  static String? _readError(String body) {
    try {
      final Object? decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] is String) {
          return decoded['detail'] as String;
        }
        for (final MapEntry<String, dynamic> entry in decoded.entries) {
          final Object? value = entry.value;
          if (value is List && value.isNotEmpty && value.first is String) {
            return '${entry.key}: ${value.first}';
          }
        }
      }
    } on Object catch (_) {
      /* ignore */
    }
    return null;
  }
}
