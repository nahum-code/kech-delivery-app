import 'package:flutter/material.dart';

import '../../theme/auth_login_tokens.dart';

class AuthLoginBrandHeader extends StatelessWidget {
  const AuthLoginBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        Text(
          'KECH DELIVERY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthLoginTokens.maroon,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 28),
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthLoginTokens.ink,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your credentials to access your dashboard.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthLoginTokens.labelGray,
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
