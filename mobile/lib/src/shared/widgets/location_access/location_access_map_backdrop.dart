import 'package:flutter/material.dart';

/// Decorative grayscale street-map texture for the location-access screen.
///
/// Uses a painted backdrop instead of [CustomerLocationAccessAssets.mapPng]
/// because that asset was a full UI mockup (logo, copy, buttons), which
/// duplicated the live Flutter widgets stacked on top.
class LocationAccessMapBackdrop extends StatelessWidget {
  const LocationAccessMapBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const Positioned.fill(
          child: CustomPaint(
            painter: _LocationAccessStreetMapPainter(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.92),
                  Colors.white,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationAccessStreetMapPainter extends CustomPainter {
  const _LocationAccessStreetMapPainter();

  static const Color _canvas = Color(0xFFE2E5EA);
  static const Color _blockFill = Color(0xFFEBEDF1);
  static const Color _street = Color(0xFFD2D6DC);
  static const Color _artery = Color(0xFFB9BFC8);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _canvas);

    final Paint streetPaint = Paint()
      ..color = _street
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018;
    final Paint arteryPaint = Paint()
      ..color = _artery
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.028;

    final List<Rect> blocks = <Rect>[
      Rect.fromLTWH(size.width * 0.04, size.height * 0.12, size.width * 0.28, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.38, size.height * 0.08, size.width * 0.24, size.height * 0.2),
      Rect.fromLTWH(size.width * 0.68, size.height * 0.14, size.width * 0.26, size.height * 0.14),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.34, size.width * 0.22, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.36, size.height * 0.32, size.width * 0.3, size.height * 0.22),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.34, size.width * 0.2, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.58, size.width * 0.34, size.height * 0.2),
      Rect.fromLTWH(size.width * 0.46, size.height * 0.6, size.width * 0.22, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.74, size.height * 0.56, size.width * 0.18, size.height * 0.22),
    ];

    final Paint blockPaint = Paint()..color = _blockFill;
    for (final Rect block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, Radius.circular(size.width * 0.012)),
        blockPaint,
      );
    }

    final List<Offset> horizontalStreets = <Offset>[
      Offset(0, size.height * 0.3),
      Offset(0, size.height * 0.52),
      Offset(0, size.height * 0.74),
    ];
    for (final Offset start in horizontalStreets) {
      canvas.drawLine(start, Offset(size.width, start.dy), streetPaint);
    }

    final List<Offset> verticalStreets = <Offset>[
      Offset(size.width * 0.34, 0),
      Offset(size.width * 0.64, 0),
    ];
    for (final Offset start in verticalStreets) {
      canvas.drawLine(start, Offset(start.dx, size.height), streetPaint);
    }

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.18),
      Offset(size.width * 0.92, size.height * 0.46),
      arteryPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.88, size.height * 0.62),
      arteryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
