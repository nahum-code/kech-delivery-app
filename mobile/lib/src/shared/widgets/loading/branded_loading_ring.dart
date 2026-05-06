import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class BrandedLoadingRing extends StatelessWidget {
  const BrandedLoadingRing({
    super.key,
    required this.progress,
    this.size = 96,
    this.strokeWidth = 10,
  });

  /// 0..1 sweep amount for the highlighted arc.
  final double progress;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandedRingPainter(
          progress: progress,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _BrandedRingPainter extends CustomPainter {
  _BrandedRingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Offset center = rect.center;
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x33FFFFFF);

    canvas.drawCircle(center, radius, trackPaint);

    final double sweep = (2 * math.pi) * progress.clamp(0, 1);
    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: <Color>[
          AppColors.accent.withValues(alpha: 0.05),
          AppColors.accent,
          AppColors.accent.withValues(alpha: 0.05),
        ],
        stops: const <double>[0.0, 0.55, 1.0],
        startAngle: -math.pi / 2,
        endAngle: 1.5 * math.pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandedRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
