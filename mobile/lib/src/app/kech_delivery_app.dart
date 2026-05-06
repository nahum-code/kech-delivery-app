import 'package:flutter/material.dart';

import '../shared/theme/app_theme.dart';
import 'app_bootstrap.dart';

/// Root application widget.
///
/// Configuration:
/// - Global theme via MaterialApp
/// - ScaffoldMessenger wraps all screens for SnackBar/BottomSheet support
/// - Delegates to AppBootstrap for auth state initialization & routing
class KechDeliveryApp extends StatelessWidget {
  const KechDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kech Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildThemeData(),
      // ScaffoldMessenger enables SnackBars/BottomSheets throughout app
      home: ScaffoldMessenger(child: const AppBootstrap()),
    );
  }
}
