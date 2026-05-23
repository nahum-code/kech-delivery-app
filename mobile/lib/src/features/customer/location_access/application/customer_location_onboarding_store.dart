import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/auth_repository.dart';

/// Persists whether this customer has already chosen how to handle location (per user id).
abstract final class CustomerLocationOnboardingStore {
  static const String _keyPrefix = 'customer_location_onboarding_v1_';

  static String _keyFor(int userId) => '$_keyPrefix$userId';

  static Future<bool> isCompletedForUser(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFor(userId)) ?? false;
  }

  static Future<void> markCompleted(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(userId), true);
  }

  /// Skip the post-login location screen when already stored or OS permission granted.
  static Future<bool> shouldSkipPrompt({
    required AuthRepository auth,
  }) async {
    if (await auth.isCustomerLocationOnboardingComplete()) {
      return true;
    }
    final PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await auth.markCustomerLocationOnboardingComplete();
      return true;
    }
    return false;
  }
}
