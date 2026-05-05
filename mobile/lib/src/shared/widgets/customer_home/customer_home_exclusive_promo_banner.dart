import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeExclusivePromoBanner extends StatelessWidget {
  const CustomerHomeExclusivePromoBanner({
    super.key,
    required this.onClaimPressed,
  });

  final VoidCallback onClaimPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CustomerHomeTokens.promoCardRadius),
      child: SizedBox(
        width: double.infinity,
        height: 168,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    CustomerHomeTokens.promoGradientStart,
                    CustomerHomeTokens.promoGradientEnd,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                'KECH',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.06),
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'EXCLUSIVE DEAL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '50% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'First order',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CustomerHomeTokens.primaryMaroon,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  onPressed: onClaimPressed,
                  child: const Text('CLAIM NOW'),
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
