import 'package:flutter/material.dart';

import '../../theme/customer_onboarding_tokens.dart';

class OnboardingStepIndicators extends StatelessWidget {
  const OnboardingStepIndicators({
    super.key,
    required this.activeIndex,
    required this.count,
  }) : assert(count > 0);

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        if (active) {
          return Padding(
            padding: EdgeInsets.only(right: index == count - 1 ? 0 : 10),
            child: Container(
              width: 28,
              height: 6,
              decoration: BoxDecoration(
                color: CustomerOnboardingTokens.burgundy,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(right: index == count - 1 ? 0 : 10),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CustomerOnboardingTokens.mutedGray,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
