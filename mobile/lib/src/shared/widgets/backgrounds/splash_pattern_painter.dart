import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashPatternPainter extends CustomPainter {
  SplashPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double spacing = 64;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), linePaint);
    }

    for (double x = 0; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), linePaint);
    }

    final Offset center = Offset(size.width * 0.5, size.height * 0.42);
    final double radius = math.min(size.width, size.height) * 0.55;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
