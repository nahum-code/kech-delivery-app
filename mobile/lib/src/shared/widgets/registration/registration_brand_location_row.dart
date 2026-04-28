import 'package:flutter/material.dart';

import '../../theme/customer_registration_tokens.dart';

/// Top bar: wordmark (serif-like weight) + Marrakech pin (customer shell).
class RegistrationBrandLocationRow extends StatelessWidget {
  const RegistrationBrandLocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CustomerRegistrationTokens.screenHorizontalPadding,
        8,
        CustomerRegistrationTokens.screenHorizontalPadding,
        12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text.rich(
              TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <InlineSpan>[
                  TextSpan(
                    text: 'Kech ',
                    style: TextStyle(
                      color: CustomerRegistrationTokens.primaryMaroon,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      height: 1.1,
                    ),
                  ),
                  TextSpan(
                    text: 'Delivery',
                    style: TextStyle(
                      color: CustomerRegistrationTokens.primaryMaroon,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.location_on_rounded, color: CustomerRegistrationTokens.primaryMaroon, size: 20),
          const SizedBox(width: 4),
          const Text(
            'Marrakech',
            style: TextStyle(
              color: CustomerRegistrationTokens.labelGray,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
