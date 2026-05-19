import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/contracts/login_actions.dart';
import '../../../../../../shared/contracts/login_credentials.dart';
import '../../../../../../shared/contracts/login_result.dart';
import '../../../../../auth/data/auth_repository.dart';
import '../../../../../auth/login/presentation/screens/login_screen.dart';
import '../../../../registration/navigation/driver_registration_navigation.dart';
import '../../navigation/driver_auth_navigation.dart';

/// Driver shell around the shared [LoginScreen] (wire fleet API / analytics here).
class DriverLoginScreen extends StatelessWidget {
  const DriverLoginScreen({super.key});

  Future<LoginResult> _submit(BuildContext context, LoginCredentials credentials) async {
    final AuthRepository auth = context.read<AuthRepository>();
    final LoginResult result = await auth.signIn(
      credentials: credentials,
      expectedApiRole: 'driver',
    );
    if (!context.mounted) {
      return result;
    }
    if (result is LoginSuccess) {
      DriverAuthNavigation.replaceWithDriverHome(context);
    }
    return result;
  }

  void _snack(BuildContext context, String message) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint(message);
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext scoped) {
        return LoginScreen(
          actions: LoginActions(
            onSubmit: (LoginCredentials c) => _submit(scoped, c),
            onForgotPassword: () => _snack(scoped, 'Forgot password (TODO)'),
            onGoogle: () => _snack(scoped, 'Google sign-in (TODO)'),
            onApple: () => _snack(scoped, 'Apple sign-in (TODO)'),
            onSignUp: () => DriverRegistrationNavigation.open(scoped),
            onPrivacyPolicy: () => _snack(scoped, 'Privacy policy (TODO)'),
            onTerms: () => _snack(scoped, 'Terms (TODO)'),
            onSupport: () => _snack(scoped, 'Support (TODO)'),
          ),
        );
      },
    );
  }
}
