import 'package:flutter/material.dart';

import '../../theme/auth_login_tokens.dart';

class AuthSocialLoginButton extends StatelessWidget {
  const AuthSocialLoginButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuthLoginTokens.fieldFill,
      borderRadius: BorderRadius.circular(AuthLoginTokens.fieldRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              leading,
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AuthLoginTokens.labelGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGoogleGlyph extends StatelessWidget {
  const AuthGoogleGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AuthLoginTokens.dividerLine),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF616161),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
