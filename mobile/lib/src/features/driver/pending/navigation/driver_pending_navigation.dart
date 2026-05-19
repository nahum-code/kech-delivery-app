import 'package:flutter/material.dart';

import '../presentation/screens/driver_pending_screen.dart';

abstract final class DriverPendingNavigation {
  static void replaceRoot(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DriverPendingScreen()),
      (_) => false,
    );
  }
}
