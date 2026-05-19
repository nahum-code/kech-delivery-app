import 'package:flutter/material.dart';

import '../../constants/customer_add_address_assets.dart';
import '../../theme/customer_add_address_tokens.dart';

class AddAddressMapPreviewCard extends StatelessWidget {
  const AddAddressMapPreviewCard({
    super.key,
    required this.height,
    this.onRecenterPressed,
  });

  final double height;
  final VoidCallback? onRecenterPressed;

  static const List<double> _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CustomerAddAddressTokens.mapCardRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(
              color: CustomerAddAddressTokens.mapCardFill,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                child: Image.asset(
                  CustomerAddAddressAssets.mapPreviewPng,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Center(
                      child: Icon(Icons.map_outlined, size: 56, color: Colors.grey.shade500),
                    );
                  },
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: CustomerAddAddressTokens.primaryMaroon,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        'Delivery point',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(14, 8),
                    painter: _TooltipTailPainter(color: CustomerAddAddressTokens.primaryMaroon),
                  ),
                  const Icon(Icons.place_rounded, color: CustomerAddAddressTokens.primaryMaroon, size: 44),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onRecenterPressed,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.my_location_rounded, color: CustomerAddAddressTokens.primaryMaroon, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TooltipTailPainter extends CustomPainter {
  _TooltipTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TooltipTailPainter oldDelegate) => oldDelegate.color != color;
}
