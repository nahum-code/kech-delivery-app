import 'package:flutter/material.dart';

import '../../theme/auth_login_tokens.dart';

class AuthLabeledDivider extends StatelessWidget {
  const AuthLabeledDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: AuthLoginTokens.dividerLine, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: AuthLoginTokens.footerMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthLoginTokens.dividerLine, height: 1)),
      ],
    );
  }
}
