import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/role_selection_bootstrap.dart';
import '../../data/driver_onboarding_repository.dart';

/// Leaves driver onboarding (clears saved registration token) and returns to role picker.
abstract final class DriverOnboardingExit {
  static Future<void> toRoleSelection(BuildContext context) async {
    await context.read<DriverOnboardingRepository>().clearOnboarding();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleSelectionBootstrap()),
      (_) => false,
    );
  }
}
