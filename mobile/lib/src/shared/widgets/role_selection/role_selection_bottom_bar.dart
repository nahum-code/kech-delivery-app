import 'package:flutter/material.dart';

import '../../contracts/role_selection_actions.dart';
import '../../theme/role_selection_tokens.dart';

class RoleSelectionBottomBar extends StatelessWidget {
  const RoleSelectionBottomBar({super.key, required this.actions});

  final RoleSelectionActions actions;

  @override
  Widget build(BuildContext context) {
    final int year = DateTime.now().year;

    return Column(
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 6,
          children: <Widget>[
            Text(
              'By continuing, you agree to our ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RoleSelectionTokens.footerMuted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: RoleSelectionTokens.termsInk,
              ),
              onPressed: actions.onTermsOfService,
              child: const Text(
                'Terms of service',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _FooterIconButton(
              tooltip: 'Language',
              icon: Icons.language_rounded,
              onPressed: actions.onLanguage,
            ),
            const SizedBox(width: 28),
            _FooterIconButton(
              tooltip: 'Account',
              icon: Icons.person_outline_rounded,
              onPressed: actions.onAccount,
            ),
            const SizedBox(width: 28),
            _FooterIconButton(
              tooltip: 'Trust & safety',
              icon: Icons.verified_user_outlined,
              onPressed: actions.onTrust,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '© $year KECH DELIVERY TECHNOLOGIES',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: RoleSelectionTokens.footerMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _FooterIconButton extends StatelessWidget {
  const _FooterIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      splashRadius: 22,
      color: RoleSelectionTokens.footerMuted,
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
    );
  }
}
