import 'package:flutter/material.dart';

import '../../auth/login/navigation/customer_auth_navigation.dart';

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
    CustomerAuthNavigation.replaceWithCustomerLogin(context);
  }
}
