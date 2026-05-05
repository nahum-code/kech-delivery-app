import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeScreenCaption extends StatelessWidget {
  const CustomerHomeScreenCaption({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Center(
        child: Text(
          'CUSTOMER - HOME',
          style: TextStyle(
            color: CustomerHomeTokens.mutedCaption,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
