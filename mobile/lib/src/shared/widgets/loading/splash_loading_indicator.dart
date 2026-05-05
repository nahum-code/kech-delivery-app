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
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() => _elapsed = elapsed);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _ringProgress(Duration elapsed) {
    const Duration period = Duration(milliseconds: 1400);
    final int ms = elapsed.inMilliseconds % period.inMilliseconds;
    return ms / period.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BrandedLoadingRing(
          progress: _ringProgress(_elapsed),
          size: widget.ringSize,
          strokeWidth: widget.ringStrokeWidth,
        ),
        const SizedBox(height: 22),
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
