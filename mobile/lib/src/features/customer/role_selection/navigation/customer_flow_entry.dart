import 'package:flutter/material.dart';

import '../../auth/login/navigation/customer_auth_navigation.dart';

/// Customer-app navigation targets after role selection (keeps routing out of shared UI).
abstract final class CustomerFlowEntry {
  static void openFromRoleSelection(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    CustomerAuthNavigation.replaceWithCustomerLogin(context);
  }
}
