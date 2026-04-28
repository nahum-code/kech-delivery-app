import 'onboarding_slide_content.dart';

/// Default onboarding deck for the customer app (extend via remote config later).
List<OnboardingSlideContent> defaultCustomerOnboardingSlides() {
  return <OnboardingSlideContent>[
    const OnboardingSlideContent(
      heroAssetPath: 'assets/images/customer_onboarding_slide_1.png',
      heroSemanticLabel: 'Courier on scooter delivering an order',
      headlineParts: (
        leading: 'On-time delivery ',
        accent: 'promise',
        trailing: '',
      ),
      body:
          'We respect your time. Experience the precision of the kinetic courier network, ensuring your food arrives fresh and fast.',
      statTitle: 'Average delivery',
      statSubtitle: '24 Minutes or less',
    ),
    const OnboardingSlideContent(
      heroAssetPath: 'assets/images/customer_onboarding_slide_1.png',
      heroSemanticLabel: 'Courier on scooter delivering an order',
      headlineParts: (
        leading: 'Track every ',
        accent: 'moment',
        trailing: '',
      ),
      body:
          'Live updates from pickup to doorstep. Clear ETAs and proactive notifications keep you in control.',
      statTitle: 'Live tracking',
      statSubtitle: 'From kitchen to door',
    ),
    const OnboardingSlideContent(
      heroAssetPath: 'assets/images/customer_onboarding_slide_1.png',
      heroSemanticLabel: 'Courier on scooter delivering an order',
      headlineParts: (
        leading: 'Built for ',
        accent: 'Marrakech',
        trailing: '',
      ),
      body:
          'Neighborhood-aware routing and local operations standards tuned for speed without sacrificing care.',
      statTitle: 'Local network',
      statSubtitle: 'Optimized city-wide',
    ),
  ];
}
