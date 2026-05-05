import 'package:flutter/material.dart';

import '../../theme/auth_login_tokens.dart';

class AuthLoginFooter extends StatelessWidget {
  const AuthLoginFooter({
    super.key,
    required this.onSignUp,
    required this.onPrivacyPolicy,
    required this.onTerms,
    required this.onSupport,
  });

  final VoidCallback onSignUp;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTerms;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 6,
          children: <Widget>[
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: AuthLoginTokens.labelGray,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AuthLoginTokens.maroon,
              ),
              onPressed: onSignUp,
              child: const Text(
                'Sign up',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _FooterLink(label: 'Privacy policy', onPressed: onPrivacyPolicy),
            _FooterLink(label: 'Terms', onPressed: onTerms),
            _FooterLink(label: 'Support', onPressed: onSupport),
          ],
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AuthLoginTokens.footerMuted,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
