import 'package:flutter/material.dart';

import 'driver_app_tokens.dart';

/// Home tab palette — re-exports shared driver app colors.
abstract final class DriverHomeTokens {
  static const Color primary = DriverAppTokens.primary;
  static const Color screenBackground = DriverAppTokens.screenBackground;
  static const Color labelMuted = DriverAppTokens.labelMuted;
  static const Color onlineBadgeBg = Color(0xFFD1FAE5);
  static const Color onlineBadgeText = Color(0xFF065F46);
  static const Color offlineBadgeBg = Color(0xFFF3F4F6);
  static const Color offlineBadgeText = DriverAppTokens.bodyGray;
  static const Color toggleTrackOn = Color(0xFFF5D0D0);
  static const Color toggleThumbOn = DriverAppTokens.primary;
  static const Color cardSurface = DriverAppTokens.cardSurface;
  static const Color ink = DriverAppTokens.ink;
  static const Color dashedBorder = Color(0xFFB8C5CE);
  static const Color emptyIconBg = Color(0xFFF2F2F2);
  static const Color emptyBody = DriverAppTokens.bodyGray;
  static const double onlineCardRadius = 24;
  static const double statCardRadius = 16;
  static const double dashedBoxRadius = 16;
}
