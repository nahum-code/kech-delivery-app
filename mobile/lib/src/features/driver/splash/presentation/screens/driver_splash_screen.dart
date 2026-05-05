import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';

/// Placeholder screen to keep customer/driver feature boundaries explicit.
///
/// Swap this for the driver-specific splash when the design is ready.
class DriverSplashScreen extends StatelessWidget {
  const DriverSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Text(
          'Driver splash (TODO)',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
