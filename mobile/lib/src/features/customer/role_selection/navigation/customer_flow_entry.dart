import 'package:flutter/material.dart';

import '../../splash/presentation/screens/customer_splash_screen.dart';

/// Customer-app navigation targets after role selection (keeps routing out of shared UI).
abstract final class CustomerFlowEntry {
  static void openFromRoleSelection(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      assert(() {
        debugPrint('CustomerFlowEntry: no Navigator in context');
        return true;
      }());
      return;
    }
    if (!context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerSplashScreen(
          navigateToOnboardingAfter: Duration(seconds: 2),
        ),
      ),
    );
  }
}
