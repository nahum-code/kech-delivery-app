import 'package:shared_preferences/shared_preferences.dart';

/// Local profile photo path per customer user (device gallery/camera).
final class CustomerProfileAvatarStore {
  static const String _keyPrefix = 'customer_profile_avatar_v1_';

  static String _keyFor(int userId) => '$_keyPrefix$userId';

  Future<String?> loadPath(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString(_keyFor(userId));
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    return path;
  }

  Future<void> savePath(int userId, String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(userId), path);
  }

  Future<void> clear(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(userId));
  }
}
