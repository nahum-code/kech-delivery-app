import 'package:flutter/material.dart';

import '../../home/presentation/screens/driver_home_placeholder_screen.dart';
import '../presentation/screens/driver_login_screen.dart';

abstract final class DriverAuthNavigation {
  static void replaceWithDriverLogin(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      assert(() {
        debugPrint('DriverAuthNavigation: no Navigator');
        return true;
      }());
      return;
    }
    if (!context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const DriverLoginScreen(),
      ),
    );
  }

  static void replaceWithDriverHome(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const DriverHomePlaceholderScreen(),
      ),
    );
  }
}
