import 'package:flutter/material.dart';

import '../../theme/customer_onboarding_tokens.dart';

/// “Kech” (burgundy, italic) + “Delivery” (black) — customer marketing header.
class KechDeliveryWordmarkOnLight extends StatelessWidget {
  const KechDeliveryWordmarkOnLight({super.key, this.fontSize = 22});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle kechStyle = TextStyle(
      color: CustomerOnboardingTokens.burgundy,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      height: 1.1,
    );
    final TextStyle deliveryStyle = TextStyle(
      color: CustomerOnboardingTokens.ink,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.1,
    );

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <InlineSpan>[
          TextSpan(text: 'Kech ', style: kechStyle),
          TextSpan(text: 'Delivery', style: deliveryStyle),
        ],
      ),
    );
  }
}
