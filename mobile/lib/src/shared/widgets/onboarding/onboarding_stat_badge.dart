import 'package:flutter/material.dart';

import '../../theme/customer_onboarding_tokens.dart';

/// Floating pill/card on the hero image (e.g. “Average delivery / 24 Minutes…”).
class OnboardingStatBadge extends StatelessWidget {
  const OnboardingStatBadge({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerOnboardingTokens.statBadgeSurface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomerOnboardingTokens.statBadgeBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: CustomerOnboardingTokens.burgundy,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.speed_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: CustomerOnboardingTokens.burgundy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CustomerOnboardingTokens.bodyGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
