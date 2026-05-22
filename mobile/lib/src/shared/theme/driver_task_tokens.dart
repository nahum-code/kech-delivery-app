import 'package:flutter/material.dart';

import 'driver_app_tokens.dart';

/// Burgundy + off-white palette for driver task / alert flows.
abstract final class DriverTaskTokens {
  static const Color primary = DriverAppTokens.primary;
  static const Color primaryDark = DriverAppTokens.primaryDark;
  static const Color canvas = DriverAppTokens.screenBackground;
  static const Color card = DriverAppTokens.cardSurface;
  static const Color ink = DriverAppTokens.ink;
  static const Color onPrimary = DriverAppTokens.onPrimary;
  static const Color routeBox = DriverAppTokens.routeBox;
  static const Color mapPlaceholder = DriverAppTokens.mapPlaceholder;
  static const Color subtitleMaroon = Color(0xFF8B5A5A);
  static const Color labelMaroon = Color(0xFFB08080);
  static const Color bodyGray = DriverAppTokens.bodyGray;
  static const Color muted = DriverAppTokens.mutedGray;
  static const Color declineBorder = Color(0xFFE8D4D4);
  static const Color tabInactive = DriverAppTokens.tabInactive;
  static const Color divider = DriverAppTokens.divider;
  static const double cardRadius = 16;
  static const double alertSheetTopRadius = 28;
}
