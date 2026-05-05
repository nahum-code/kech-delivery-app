import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_onboarding_tokens.dart';
import '../../../../../shared/widgets/onboarding/onboarding_hero_card.dart';
import '../../../../../shared/widgets/onboarding/onboarding_stat_badge.dart';
import '../../domain/onboarding_slide_content.dart';

class CustomerOnboardingSlidePage extends StatelessWidget {
  const CustomerOnboardingSlidePage({super.key, required this.content});

  final OnboardingSlideContent content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CustomerOnboardingTokens.screenHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 8),
                  OnboardingHeroCard(
                    imageAssetPath: content.heroAssetPath,
                    semanticLabel: content.heroSemanticLabel,
                    badge: OnboardingStatBadge(
                      title: content.statTitle,
                      subtitle: content.statSubtitle,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        color: CustomerOnboardingTokens.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                      children: <InlineSpan>[
                        TextSpan(text: content.headlineParts.leading),
                        TextSpan(
                          text: content.headlineParts.accent,
                          style: const TextStyle(color: CustomerOnboardingTokens.burgundy),
                        ),
                        TextSpan(text: content.headlineParts.trailing),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content.body,
                    style: const TextStyle(
                      color: CustomerOnboardingTokens.bodyGray,
                      fontSize: 16,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
