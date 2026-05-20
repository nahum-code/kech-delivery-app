import 'dart:io';

import 'package:flutter/foundation.dart';

import 'dev_api_config.dart';

/// Resolves the Django API origin (no trailing slash).
///
/// | Device | Default |
/// |--------|---------|
/// | Android emulator | `http://10.0.2.2:8000` |
/// | Physical Android | [DevApiConfig.physicalDeviceHost] (edit that file) |
/// | iOS simulator / desktop | `http://127.0.0.1:8000` |
///
/// Override anytime: `--dart-define=API_BASE_URL=http://YOUR_IP:8000`
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
      if (_isAndroidEmulator()) {
        return _androidEmulatorHost;
      }
      return DevApiConfig.physicalDeviceHost.replaceAll(RegExp(r'/+$'), '');
    }
    return _localHost;
  }

  /// Emulator exposes this socket; absent on physical hardware.
  static bool _isAndroidEmulator() {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return File('/dev/socket/qemu_pipe').existsSync();
    } on Object {
      return false;
    }
  }
}
