import 'package:flutter/material.dart';

import '../../constants/customer_location_access_assets.dart';
import '../../theme/customer_location_access_tokens.dart';

/// Full-bleed map image with grayscale treatment and a light bottom scrim for legibility.
class LocationAccessMapBackdrop extends StatelessWidget {
  const LocationAccessMapBackdrop({super.key});

  static const List<double> _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
            child: Image.asset(
              CustomerLocationAccessAssets.mapPng,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return ColoredBox(
                  color: CustomerLocationAccessTokens.tileBackground,
                  child: Center(
                    child: Icon(Icons.map_outlined, size: 72, color: Colors.grey.shade500),
                  ),
                );
              },
            ),
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
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0.92),
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