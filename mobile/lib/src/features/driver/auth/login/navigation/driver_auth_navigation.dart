import 'package:flutter/material.dart';

import '../../../shell/presentation/screens/driver_shell_screen.dart';
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

  /// Lands on driver shell (home tab with online/offline toggle + bottom nav).
  static void replaceWithDriverHome(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const DriverShellScreen(),
      ),
    );
  }
}
