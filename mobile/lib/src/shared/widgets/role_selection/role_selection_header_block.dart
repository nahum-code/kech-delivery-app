import 'package:flutter/material.dart';

import '../../theme/role_selection_tokens.dart';

class RoleSelectionHeaderBlock extends StatelessWidget {
  const RoleSelectionHeaderBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <InlineSpan>[
              TextSpan(
                text: 'KECH ',
                style: TextStyle(
                  color: RoleSelectionTokens.primaryBurgundy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              TextSpan(
                text: 'DELIVERY',
                style: TextStyle(
                  color: RoleSelectionTokens.deliveryGray,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Fast. Reliable.',
          style: TextStyle(
            color: RoleSelectionTokens.headlineInk,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Join the fastest delivery network in the Addis City.',
          style: TextStyle(
            color: RoleSelectionTokens.subheadGray,
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
