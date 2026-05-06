import 'package:flutter/material.dart';

import '../../theme/app_text_styles.dart';
import 'branded_loading_ring.dart';

class SplashLoadingIndicator extends StatefulWidget {
  const SplashLoadingIndicator({
    super.key,
    required this.title,
    required this.subtitle,
    this.ringSize = 112,
    this.ringStrokeWidth = 11,
  });

  final String title;
  final String subtitle;
  final double ringSize;
  final double ringStrokeWidth;

  @override
  State<SplashLoadingIndicator> createState() => _SplashLoadingIndicatorState();
}

class _SplashLoadingIndicatorState extends State<SplashLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return BrandedLoadingRing(
              progress: _controller.value,
              size: widget.ringSize,
              strokeWidth: widget.ringStrokeWidth,
            );
          },
        ),        const SizedBox(height: 22),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.systemCheckLabel,
        ),
        const SizedBox(height: 10),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.systemCheckMessage,
        ),
      ],
    );
  }
}
