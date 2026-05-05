import 'package:flutter/material.dart';

import '../../../location_access/presentation/screens/customer_location_access_screen.dart';
import '../../home/presentation/screens/customer_home_screen.dart';
import '../presentation/screens/customer_login_screen.dart';

abstract final class CustomerAuthNavigation {
  static void replaceWithCustomerLogin(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      assert(() {
        debugPrint('CustomerAuthNavigation: no Navigator');
        return true;
      }());
      return;
    }
    if (!context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerLoginScreen(),
      ),
    );
  }

  static void replaceWithCustomerLocationAccess(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerLocationAccessScreen(),
      ),
    );
  }

  static void replaceWithCustomerHome(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerHomeScreen(),
      ),
    );
  }

  /// Clears pushed post-login routes (e.g. manual address) and lands on the customer home shell.
  static void finishPostLoginFlowToHome(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerHomeScreen(),
      ),
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
