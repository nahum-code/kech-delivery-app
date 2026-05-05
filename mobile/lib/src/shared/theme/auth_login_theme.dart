import 'package:flutter/material.dart';

import 'auth_login_tokens.dart';

abstract final class AuthLoginTheme {
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AuthLoginTokens.maroon,
      brightness: Brightness.light,
      surface: AuthLoginTokens.canvas,
      error: AuthLoginTokens.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AuthLoginTokens.canvas,
      colorScheme: scheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuthLoginTokens.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthLoginTokens.fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthLoginTokens.fieldRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthLoginTokens.fieldRadius),
          borderSide: const BorderSide(color: AuthLoginTokens.maroon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthLoginTokens.fieldRadius),
          borderSide: const BorderSide(color: AuthLoginTokens.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        hintStyle: const TextStyle(color: AuthLoginTokens.hintGray, fontSize: 15),
      ),
    );
  }
}
