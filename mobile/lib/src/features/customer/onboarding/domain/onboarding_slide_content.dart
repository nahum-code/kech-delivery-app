import 'package:flutter/foundation.dart';

/// Static copy + assets for one onboarding page.
@immutable
class OnboardingSlideContent {
  const OnboardingSlideContent({
    required this.heroAssetPath,
    required this.heroSemanticLabel,
    required this.headlineParts,
    required this.body,
    required this.statTitle,
    required this.statSubtitle,
  });

  final String heroAssetPath;
  final String heroSemanticLabel;

  /// Rendered in order: [leading] is black, [accent] is burgundy, [trailing] is black.
  final ({String leading, String accent, String trailing}) headlineParts;

  final String body;
  final String statTitle;
  final String statSubtitle;
}
