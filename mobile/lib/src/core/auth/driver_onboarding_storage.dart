import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists driver onboarding session (registration token) until approval/login.
final class DriverOnboardingStorage {
  DriverOnboardingStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'kech_driver_onboarding_v1';
  final FlutterSecureStorage _storage;

  Future<DriverOnboardingSnapshot?> load() async {
    final String? raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return DriverOnboardingSnapshot.fromJson(map);
    } on Object catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> save(DriverOnboardingSnapshot snapshot) async {
    await _storage.write(key: _key, value: jsonEncode(snapshot.toJson()));
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}

final class DriverOnboardingSnapshot {
  const DriverOnboardingSnapshot({
    required this.userId,
    required this.phone,
    required this.registrationToken,
    this.approvalStatus = 'pending',
  });

  final int userId;
  final String phone;
  final String registrationToken;
  final String approvalStatus;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user_id': userId,
        'phone': phone,
        'registration_token': registrationToken,
        'approval_status': approvalStatus,
      };

  factory DriverOnboardingSnapshot.fromJson(Map<String, dynamic> json) {
    return DriverOnboardingSnapshot(
      userId: (json['user_id'] as num).toInt(),
      phone: json['phone'] as String,
      registrationToken: json['registration_token'] as String,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
    );
  }

  DriverOnboardingSnapshot copyWith({String? approvalStatus}) {
    return DriverOnboardingSnapshot(
      userId: userId,
      phone: phone,
      registrationToken: registrationToken,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
}
