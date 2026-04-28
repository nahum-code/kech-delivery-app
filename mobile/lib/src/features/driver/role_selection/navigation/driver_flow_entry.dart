import 'package:flutter/material.dart';

import '../../auth/login/navigation/driver_auth_navigation.dart';

/// Driver-app navigation targets after role selection (keeps routing out of shared UI).
abstract final class DriverFlowEntry {
  static void openFromRoleSelection(BuildContext context) {
    DriverAuthNavigation.replaceWithDriverLogin(context);
  }
}
