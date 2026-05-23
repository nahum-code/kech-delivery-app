import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../location_access/application/customer_location_onboarding_store.dart';
import '../../../location_access/presentation/screens/customer_location_access_screen.dart';
import '../../../shell/presentation/screens/customer_shell_screen.dart';
import '../presentation/screens/customer_login_screen.dart';

abstract final class CustomerAuthNavigation {
  static void replaceWithCustomerLogin(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null) {
      assert(() {
        debugPrint('CustomerAuthNavigation: no Navigator');
        return true;
      }());
      return;
    }
    if (!context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerLoginScreen(),
      ),
    );
  }

  /// After sign-in: home if location was already chosen, otherwise the location prompt.
  static Future<void> continueAfterCustomerAuth(BuildContext context) async {
    final AuthRepository auth = context.read<AuthRepository>();
    if (auth.currentSession?.userId == null) {
      replaceWithCustomerLogin(context);
      return;
    }
    final bool skip = await CustomerLocationOnboardingStore.shouldSkipPrompt(auth: auth);
    if (!context.mounted) {
      return;
    }
    if (skip) {
      replaceWithCustomerHome(context);
    } else {
      replaceWithCustomerLocationAccess(context);
    }
  }

  static void replaceWithCustomerLocationAccess(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerLocationAccessScreen(),
      ),
    );
  }

  static void replaceWithCustomerHome(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerShellScreen(),
      ),
    );
  }

  /// Clears pushed post-login routes (e.g. manual address) and lands on the customer home shell.
  static void finishPostLoginFlowToHome(BuildContext context) {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator == null || !context.mounted) {
      return;
    }
    navigator.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerShellScreen(),
      ),
      (Route<dynamic> route) => route.isFirst,
    );
  }
}
