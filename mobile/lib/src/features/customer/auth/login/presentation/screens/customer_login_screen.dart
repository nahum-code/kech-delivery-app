import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../shared/contracts/login_actions.dart';
import '../../../../../../shared/contracts/login_credentials.dart';
import '../../../../../../shared/contracts/login_result.dart';
import '../../../../../auth/data/auth_repository.dart';
import '../../../../../auth/login/presentation/screens/login_screen.dart';
import '../../navigation/customer_auth_navigation.dart';
import '../../../../registration/navigation/customer_registration_navigation.dart';

/// Customer shell around the shared [LoginScreen] (wire API / analytics here).
class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  Future<LoginResult> _submit(BuildContext context, LoginCredentials credentials) async {
    final AuthRepository auth = context.read<AuthRepository>();
    final LoginResult result = await auth.signIn(
      credentials: credentials,
      expectedApiRole: 'customer',
    );
    if (!context.mounted) {
      return result;
    }
    if (result is LoginSuccess) {
      await CustomerAuthNavigation.continueAfterCustomerAuth(context);
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
            onSignUp: () => CustomerRegistrationNavigation.openFromLogin(scoped),
            onPrivacyPolicy: () => _snack(scoped, 'Privacy policy (TODO)'),
            onTerms: () => _snack(scoped, 'Terms (TODO)'),
            onSupport: () => _snack(scoped, 'Support (TODO)'),
          ),
        );
      },
    );
  }
}
