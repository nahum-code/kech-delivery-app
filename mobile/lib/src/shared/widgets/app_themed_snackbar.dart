import 'package:flutter/material.dart';

import '../theme/driver_app_tokens.dart';

enum AppSnackTone { error, success, info }

/// Burgundy-themed SnackBar — use instead of default Material snack styling.
void showAppThemedSnackBar(
  BuildContext context, {
  required String message,
  AppSnackTone tone = AppSnackTone.error,
  Duration duration = const Duration(seconds: 4),
}) {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    debugPrint(message);
    return;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: duration,
      backgroundColor: switch (tone) {
        AppSnackTone.error => const Color(0xFF5C1A1A),
        AppSnackTone.success => const Color(0xFF1A5C34),
        AppSnackTone.info => DriverAppTokens.primary,
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            switch (tone) {
              AppSnackTone.error => Icons.error_outline,
              AppSnackTone.success => Icons.check_circle_outline,
              AppSnackTone.info => Icons.info_outline,
            },
            color: DriverAppTokens.onPrimary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: DriverAppTokens.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
