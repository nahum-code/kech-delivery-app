import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';

class CustomerInboxScreen extends StatelessWidget {
  const CustomerInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CustomerCheckoutTokens.canvas,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Inbox',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(color: CustomerCheckoutTokens.bodyGray),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
