import 'package:flutter/material.dart';

import '../shared/theme/app_theme.dart';
import 'role_selection_bootstrap.dart';

class KechDeliveryApp extends StatelessWidget {
  const KechDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kech Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildThemeData(),
      home: const RoleSelectionBootstrap(),
    );
  }
}
