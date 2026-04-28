import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'login_credentials.dart';
import 'login_result.dart';

typedef LoginSubmitHandler = Future<LoginResult> Function(LoginCredentials credentials);

@immutable
class LoginActions {
  const LoginActions({
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onGoogle,
    required this.onApple,
    required this.onSignUp,
    required this.onPrivacyPolicy,
    required this.onTerms,
    required this.onSupport,
  });

  final LoginSubmitHandler onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onSignUp;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTerms;
  final VoidCallback onSupport;
}
