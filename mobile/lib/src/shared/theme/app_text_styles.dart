import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle screenTag = TextStyle(
    color: AppColors.textMuted,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.2,
  );

  static const TextStyle appTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 48,
    height: 1.05,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle appSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 30,
    height: 1.25,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle systemCheckLabel = TextStyle(
    color: AppColors.textMuted,
    fontSize: 19,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
  );

  static const TextStyle systemCheckMessage = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle statusLabel = TextStyle(
    color: AppColors.textMuted,
    fontSize: 16,
    letterSpacing: 1.4,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle statusValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 43,
    fontWeight: FontWeight.w600,
  );
}
