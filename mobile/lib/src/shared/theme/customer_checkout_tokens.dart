import 'package:flutter/material.dart';

/// Checkout / payment flow — matches production order & payment screens (#800020).
abstract final class CustomerCheckoutTokens {
  static const Color primaryMaroon = Color(0xFF800020);
  static const Color canvas = Color(0xFFF8F8F8);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color bodyGray = Color(0xFF5C5C5C);
  static const Color mutedGray = Color(0xFF9A9A9A);
  static const Color fieldFill = Color(0xFFF2F2F2);
  static const Color journeyInactive = Color(0xFFD0D0D0);
  static const Color deliveryTeal = Color(0xFF0F4A47);
  static const Color dropoffTint = Color(0xFFF5E8EA);
  static const Color chapaBlue = Color(0xFF2563EB);
  static const Color mapPlaceholder = Color(0xFFE8EFE4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const double screenPadding = 20;
  static const double cardRadius = 16;
  static const double buttonRadius = 28;
  static const double defaultDeliveryFee = 25;

  static TextStyle sectionTitle(BuildContext context) => Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w800,
        color: ink,
        fontSize: 16,
      );
}
