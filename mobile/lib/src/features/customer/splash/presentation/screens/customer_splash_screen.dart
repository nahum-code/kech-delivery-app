import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../auth/login/navigation/customer_auth_navigation.dart';
import '../../../onboarding/presentation/screens/customer_onboarding_screen.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/backgrounds/gradient_background.dart';
import '../../../../../shared/widgets/backgrounds/splash_pattern_painter.dart';
import '../../../../../shared/widgets/branding/app_logo.dart';
import '../../../../../shared/widgets/cards/status_info_card.dart';
import '../../../../../shared/widgets/loading/splash_loading_indicator.dart';

class CustomerSplashScreen extends StatefulWidget {
  const CustomerSplashScreen({
    super.key,
    this.navigateToOnboardingAfter,
  });

  /// When non-null, replaces the route with [CustomerOnboardingScreen] after the delay.
  final Duration? navigateToOnboardingAfter;

  static const String _logoAssetPath = 'assets/images/customer_splash_logo.png';

  @override
  State<CustomerSplashScreen> createState() => _CustomerSplashScreenState();
}

class _CustomerSplashScreenState extends State<CustomerSplashScreen> {
  Timer? _onboardingTimer;

  @override
  void initState() {
    super.initState();
    final Duration? delay = widget.navigateToOnboardingAfter;
    if (delay == null) {
      return;
    }
    _onboardingTimer = Timer(delay, _openOnboardingIfMounted);
  }

  @override
  void dispose() {
    _onboardingTimer?.cancel();
    super.dispose();
  }

  void _openOnboardingIfMounted() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CustomerOnboardingScreen(
          onSkip: CustomerAuthNavigation.replaceWithCustomerLogin,
          onFinished: CustomerAuthNavigation.replaceWithCustomerLogin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.splashBackgroundDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: GradientBackground(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: SplashPatternPainter(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      const Text(
                        'CUSTOMER - SPLASH SCREEN',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.screenTag,
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _LogoWithPointer(logoAssetPath: CustomerSplashScreen._logoAssetPath),
                            const SizedBox(height: 34),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: AppTextStyles.appTitle,
                                children: <InlineSpan>[
                                  TextSpan(text: 'Kech '),
                                  TextSpan(
                                    text: 'Delivery',
                                    style: TextStyle(color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Marrakech speed, editorial precision.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.appSubtitle,
                            ),
                            const SizedBox(height: 44),
                            const SplashLoadingIndicator(
                              title: 'SYSTEM CHECK',
                              subtitle: 'Calibrating route precision',
                            ),
                          ],
                        ),
                      ),
                      const StatusInfoCard(
                        label: 'Status',
                        value: 'On-time reliability: 99.8%',
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoWithPointer extends StatelessWidget {
  const _LogoWithPointer({required this.logoAssetPath});

  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                Colors.white.withOpacity(0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
        AppLogo(assetPath: logoAssetPath, size: 240, semanticLabel: 'Kech Delivery logo'),
        const Positioned(
          right: 10,
          top: 92,
          child: _PointerAccent(),
        ),
      ],
    );
  }
}

class _PointerAccent extends StatelessWidget {
  const _PointerAccent();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(34, 34),
      painter: _PointerPainter(color: AppColors.accent),
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, size.height * 0.15)
      ..lineTo(size.width * 0.92, size.height * 0.48)
      ..lineTo(size.width * 0.22, size.height * 0.92)
      ..close();

    final Paint fill = Paint()..color = color;
    final Paint stroke = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
