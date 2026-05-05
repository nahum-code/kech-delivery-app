import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session_snapshot.dart';

/// Persists JWT session material for the mobile client.
abstract interface class TokenPersistence {
  Future<void> save(AuthSessionSnapshot snapshot);
  Future<AuthSessionSnapshot?> load();
  Future<void> clear();
}

/// Production persistence (Keychain / Keystore).
final class SecureTokenPersistence implements TokenPersistence {
  SecureTokenPersistence({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'kech_auth_session_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(AuthSessionSnapshot snapshot) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(snapshot.toJson()));
  }

  @override
  Future<AuthSessionSnapshot?> load() async {
    final String? raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return AuthSessionSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (e, st) {
      debugPrint('Corrupt auth session: $e\n$st');
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
  }
}

/// In-memory persistence for tests / hermetic runs.
final class MemoryTokenPersistence implements TokenPersistence {
  AuthSessionSnapshot? _snapshot;

  @override
  Future<void> clear() async {
    _snapshot = null;
  }

  @override
  Future<AuthSessionSnapshot?> load() async => _snapshot;

  @override
  Future<void> save(AuthSessionSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}
