import 'package:flutter/material.dart';

import '../../constants/customer_location_access_assets.dart';
import '../../theme/customer_location_access_tokens.dart';

class LocationAccessBrandHeader extends StatelessWidget {
  const LocationAccessBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: CustomerLocationAccessTokens.primaryMaroon,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    CustomerLocationAccessAssets.brandLogoPng,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Icon(Icons.local_shipping_outlined, color: Colors.teal.shade600, size: 22);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Kech',
                style: TextStyle(
                  color: CustomerLocationAccessTokens.primaryMaroon,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'DELIVERY ESSENTIALS',
                style: TextStyle(
                  color: CustomerLocationAccessTokens.mutedInk,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
