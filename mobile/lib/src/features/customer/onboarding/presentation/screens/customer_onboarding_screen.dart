import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/theme/customer_onboarding_tokens.dart';
import '../../../../../shared/widgets/branding/kech_delivery_wordmark.dart';
import '../../../../../shared/widgets/buttons/onboarding_next_button.dart';
import '../../../../../shared/widgets/onboarding/onboarding_step_indicators.dart';
import '../../domain/customer_onboarding_slides.dart';
import '../../domain/onboarding_slide_content.dart';
import '../widgets/customer_onboarding_slide_page.dart';

typedef CustomerOnboardingSkipHandler = void Function(BuildContext context);
typedef CustomerOnboardingCompleteHandler = void Function(BuildContext context);

String _slideCounterLabel({required int zeroBasedIndex, required int totalSlides}) {
  final int current = zeroBasedIndex + 1;
  final String currentLabel = current.toString().padLeft(2, '0');
  final String totalLabel = totalSlides.toString().padLeft(2, '0');
  return 'SLIDE $currentLabel — $totalLabel';
}

class CustomerOnboardingScreen extends StatefulWidget {
  const CustomerOnboardingScreen({
    super.key,
    this.slides,
    this.onSkip,
    this.onFinished,
  });

  final List<OnboardingSlideContent>? slides;
  final CustomerOnboardingSkipHandler? onSkip;
  final CustomerOnboardingCompleteHandler? onFinished;

  @override
  State<CustomerOnboardingScreen> createState() => _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends State<CustomerOnboardingScreen> {
  late final PageController _pageController;
  late final List<OnboardingSlideContent> _slides;

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _slides = widget.slides ?? defaultCustomerOnboardingSlides();
    assert(_slides.isNotEmpty, 'Onboarding requires at least one slide.');
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleSkip() {
    final CustomerOnboardingSkipHandler? handler = widget.onSkip;
    if (handler != null) {
      handler(context);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleNext() {
    final bool isLast = _pageIndex >= _slides.length - 1;
    if (!isLast) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final CustomerOnboardingCompleteHandler? handler = widget.onFinished;
    if (handler != null) {
      handler(context);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CustomerOnboardingTokens.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CustomerOnboardingTokens.burgundy,
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: base,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: CustomerOnboardingTokens.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerOnboardingTokens.screenHorizontalPadding,
                    8,
                    CustomerOnboardingTokens.screenHorizontalPadding,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Expanded(child: KechDeliveryWordmarkOnLight()),
                      TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: CustomerOnboardingTokens.mutedGray,
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (int index) => setState(() => _pageIndex = index),
                    itemBuilder: (BuildContext context, int index) {
                      return CustomerOnboardingSlidePage(content: _slides[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerOnboardingTokens.screenHorizontalPadding,
                    8,
                    CustomerOnboardingTokens.screenHorizontalPadding,
                    4,
                  ),
                  child: OnboardingStepIndicators(
                    activeIndex: _slides.isEmpty
                        ? 0
                        : _pageIndex.clamp(0, _slides.length - 1),
                    count: _slides.isEmpty ? 1 : _slides.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerOnboardingTokens.screenHorizontalPadding,
                    12,
                    CustomerOnboardingTokens.screenHorizontalPadding,
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _slideCounterLabel(
                            zeroBasedIndex: _pageIndex,
                            totalSlides: _slides.length,
                          ),
                          style: const TextStyle(
                            color: CustomerOnboardingTokens.mutedGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      OnboardingNextButton(onPressed: _slides.isEmpty ? null : _handleNext),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
