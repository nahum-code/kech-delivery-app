/// Resolves the Django API origin (no trailing slash).
///
/// **Android emulator:** use `--dart-define=API_BASE_URL=http://10.0.2.2:8000`
/// **iOS simulator / desktop:** default `http://127.0.0.1:8000` works against local `runserver`.
abstract final class ApiBaseUrl {
  static const String _envKey = 'API_BASE_URL';

  static String resolve() {
    const String fromEnv = String.fromEnvironment(_envKey);
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceAll(RegExp(r'/+$'), '');
    }
    return 'http://127.0.0.1:8000';
  }
}
