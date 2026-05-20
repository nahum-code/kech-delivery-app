import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../driver/data/driver_onboarding_repository.dart';
import '../../auth/login/navigation/customer_auth_navigation.dart';

/// Customer-app navigation targets after role selection (keeps routing out of shared UI).
abstract final class CustomerFlowEntry {
  static Future<void> openFromRoleSelection(BuildContext context) async {
    if (!context.mounted) {
      return;
    }
    // Drop stale driver onboarding so the next cold start does not reopen pending.
    await context.read<DriverOnboardingRepository>().clearOnboarding();
    if (!context.mounted) {
      return;
    }
    CustomerAuthNavigation.replaceWithCustomerLogin(context);
  }
}
