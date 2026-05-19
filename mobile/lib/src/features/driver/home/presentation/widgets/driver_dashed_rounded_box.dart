import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../shared/theme/driver_home_tokens.dart';

/// Rounded rectangle with dashed stroke (active deliveries empty state).
class DriverDashedRoundedBox extends StatelessWidget {
  const DriverDashedRoundedBox({
    super.key,
    required this.child,
    this.radius = DriverHomeTokens.dashedBoxRadius,
    this.color = DriverHomeTokens.dashedBorder,
    this.padding = const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
  });

  final Widget child;
  final double radius;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(radius: radius, color: color),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      const double dash = 6;
      const double gap = 5;
      while (distance < metric.length) {
        final double next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}
