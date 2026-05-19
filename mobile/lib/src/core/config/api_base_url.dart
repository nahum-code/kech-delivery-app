import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Resolves the Django API origin (no trailing slash).
///
/// **Android emulator:** defaults to `http://10.0.2.2:8000` (host loopback).
/// **iOS simulator / desktop:** defaults to `http://127.0.0.1:8000`.
/// Override anytime: `--dart-define=API_BASE_URL=http://YOUR_HOST:8000`
abstract final class ApiBaseUrl {
  static const String _envKey = 'API_BASE_URL';
  static const String _androidEmulatorHost = 'http://10.0.2.2:8000';
  static const String _localHost = 'http://127.0.0.1:8000';

  static String resolve() {
    const String fromEnv = String.fromEnvironment(_envKey);
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/+$'), '');
    }
    if (!kIsWeb && Platform.isAndroid) {
      return _androidEmulatorHost;
    }
    return _localHost;
  }
}
