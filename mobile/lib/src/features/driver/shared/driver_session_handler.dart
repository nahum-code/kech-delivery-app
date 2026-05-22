import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/http/api_error_message.dart';
import '../../../shared/widgets/app_themed_snackbar.dart';
import '../../auth/data/auth_repository.dart';
import '../auth/login/navigation/driver_auth_navigation.dart';

/// Shows themed errors; signs out and returns to login when the JWT expired.
Future<void> handleDriverApiError(BuildContext context, Object error) async {
  final String message = userMessageFrom(error);
  if (!context.mounted) {
    return;
  }

  if (isSessionExpiredError(error)) {
    showAppThemedSnackBar(
      context,
      message: message,
      tone: AppSnackTone.info,
    );
    await context.read<AuthRepository>().signOut();
    if (!context.mounted) {
      return;
    }
    DriverAuthNavigation.replaceWithDriverLogin(context);
    return;
  }

  showAppThemedSnackBar(context, message: message, tone: AppSnackTone.error);
}
