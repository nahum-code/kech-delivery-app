import 'package:flutter/material.dart';

import '../../pending/navigation/driver_pending_navigation.dart';
import '../presentation/screens/driver_otp_screen.dart';

abstract final class DriverOtpNavigation {
  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DriverOtpScreen()),
    );
  }

  static void replaceWithPending(BuildContext context) {
    DriverPendingNavigation.replaceRoot(context);
  }
}
