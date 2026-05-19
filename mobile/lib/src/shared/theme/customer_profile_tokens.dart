import 'package:flutter/material.dart';

/// Customer profile screen — matches production profile mockup.
abstract final class CustomerProfileTokens {
  static const Color canvas = Color(0xFFFDFBF9);
  static const Color primaryMaroon = Color(0xFF6A0D18);
  static const Color titleInk = Color(0xFF3D2C2C);
  static const Color bodyMuted = Color(0xFF8A7A72);
  static const Color sectionInk = Color(0xFF3D2C2C);
  static const Color tileFill = Color(0xFFF3F3F3);
  static const Color iconTileSurface = Color(0xFFFFFFFF);
  static const Color chevronGray = Color(0xFFB0B0B0);
  static const Color eliteBadgeFill = Color(0xFFF5E8EA);
  static const Color avatarFill = Color(0xFFFFD4C4);
  static const Color homeChipFill = Color(0xFFDCEEFF);
  static const Color homeChipText = Color(0xFF2563EB);
  static const Color workChipFill = Color(0xFFF5E8EA);
  static const Color workChipText = Color(0xFF6A0D18);
  static const Color subtitleGray = Color(0xFF9A9A9A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8E8E8);

  static const double screenPadding = 20;
  static const double tileRadius = 16;
  static const double iconTileRadius = 12;
  static const double iconTileSize = 40;
  static const double avatarRadius = 40;
  static const double editBadgeRadius = 14;

  static const TextStyle screenCaption = TextStyle(
    color: primaryMaroon,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const TextStyle appBarTitle = TextStyle(
    color: primaryMaroon,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: sectionInk,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle tileTitle = TextStyle(
    color: titleInk,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle userName = TextStyle(
    color: titleInk,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static const TextStyle userEmail = TextStyle(
    color: bodyMuted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
