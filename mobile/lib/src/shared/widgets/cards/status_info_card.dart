import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class StatusInfoCard extends StatelessWidget {
  const StatusInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.leading,
  });

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Row(
          children: <Widget>[
            leading ??
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label.toUpperCase(), style: AppTextStyles.statusLabel),
                  const SizedBox(height: 6),
                  Text(value, style: AppTextStyles.statusValue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
