import 'package:flutter/material.dart';

import '../../../../shared/theme/driver_home_tokens.dart';

/// Pill badge: ● ONLINE / ● OFFLINE (home + tasks headers).
class DriverOnlineStatusBadge extends StatelessWidget {
  const DriverOnlineStatusBadge({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? DriverHomeTokens.onlineBadgeBg : DriverHomeTokens.offlineBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOnline ? '● ONLINE' : '● OFFLINE',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
          color: isOnline ? DriverHomeTokens.onlineBadgeText : DriverHomeTokens.offlineBadgeText,
        ),
      ),
    );
  }
}
