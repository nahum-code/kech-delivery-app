import 'package:flutter/material.dart';

import '../../theme/customer_onboarding_tokens.dart';

/// Rounded hero image with an optional bottom-left overlay (e.g. stat badge).
class OnboardingHeroCard extends StatelessWidget {
  const OnboardingHeroCard({
    super.key,
    required this.imageAssetPath,
    required this.semanticLabel,
    this.badge,
    this.widthOverHeight = 0.72,
  });

  final String imageAssetPath;
  final String semanticLabel;
  final Widget? badge;

  /// Width ÷ height for the hero frame (taller hero uses smaller values).
  final double widthOverHeight;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widthOverHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CustomerOnboardingTokens.heroBorderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(
              color: CustomerOnboardingTokens.statBadgeSurface,
              child: Image.asset(
                imageAssetPath,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: CustomerOnboardingTokens.mutedGray,
                    ),
                  );
                },
              ),
            ),
            if (badge != null)
              Positioned(
                left: 16,
                bottom: 16,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}
