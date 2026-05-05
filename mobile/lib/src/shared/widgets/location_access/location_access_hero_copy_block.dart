import 'package:flutter/material.dart';

import '../../theme/customer_location_access_tokens.dart';

class LocationAccessHeroCopyBlock extends StatelessWidget {
  const LocationAccessHeroCopyBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Find your perfect spot.',
          style: TextStyle(
            color: CustomerLocationAccessTokens.heroInk,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'To deliver your favorites with kinetic speed, we need to know where you are.',
          style: TextStyle(
            color: CustomerLocationAccessTokens.bodyInk,
            fontSize: 15,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
