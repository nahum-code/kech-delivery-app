import 'package:flutter/material.dart';

import '../../theme/customer_registration_tokens.dart';

/// White sheet with large top radii (form lives inside).
class RegistrationCardShell extends StatelessWidget {
  const RegistrationCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: CustomerRegistrationTokens.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CustomerRegistrationTokens.cardTopRadius),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CustomerRegistrationTokens.cardTopRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
