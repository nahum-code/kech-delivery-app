import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/role_selection_assets.dart';
import '../../theme/role_selection_tokens.dart';

/// Bottom-right decorative layer (PNG with vector fallback if the asset fails).
class RoleSelectionWatermark extends StatelessWidget {
  const RoleSelectionWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double side = math.min(constraints.maxWidth, constraints.maxHeight) * 0.55;
        return Positioned(
          right: -side * 0.08,
          bottom: -side * 0.12,
          width: side,
          height: side,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.22,
              child: Image.asset(
                RoleSelectionAssets.watermarkPng,
                fit: BoxFit.contain,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return CustomPaint(painter: _WatermarkFallbackPainter());
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WatermarkFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = RoleSelectionTokens.dividerLine;

    final Offset c = Offset(size.width * 0.62, size.height * 0.55);
    canvas.drawCircle(c, size.width * 0.42, ring);
    canvas.drawCircle(c, size.width * 0.30, ring);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
