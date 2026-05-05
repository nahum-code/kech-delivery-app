import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.assetPath,
    this.size = 220,
    this.semanticLabel,
  });

  final String assetPath;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 72);
        },
      ),
    );
  }
}
