import 'package:flutter/material.dart';

import '../../theme/customer_location_access_tokens.dart';

class LocationAccessPrecisionTile extends StatelessWidget {
  const LocationAccessPrecisionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerLocationAccessTokens.tileBackground,
        borderRadius: BorderRadius.circular(CustomerLocationAccessTokens.tileRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CustomerLocationAccessTokens.primaryMaroon,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.place_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Precision delivery',
                    style: TextStyle(
                      color: CustomerLocationAccessTokens.bodyInk,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time tracking for every order.',
                    style: TextStyle(
                      color: CustomerLocationAccessTokens.mutedInk,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
