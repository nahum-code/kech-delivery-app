import 'package:flutter/material.dart';

import 'role_selection_tokens.dart';

abstract final class RoleSelectionTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      splashColor: RoleSelectionTokens.primaryBurgundy.withOpacity(0.08),
      highlightColor: RoleSelectionTokens.primaryBurgundy.withOpacity(0.06),
      colorScheme: ColorScheme.fromSeed(
        seedColor: RoleSelectionTokens.primaryBurgundy,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
    );
  }
}
