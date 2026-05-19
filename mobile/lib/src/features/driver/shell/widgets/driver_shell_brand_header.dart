import 'package:flutter/material.dart';

import '../../../../shared/theme/driver_home_tokens.dart';
import '../../../../shared/theme/driver_task_tokens.dart';

/// Top bar: menu + stacked KECH DELIVERY wordmark (alert / tasks style mockups).
class DriverShellBrandHeader extends StatelessWidget {
  const DriverShellBrandHeader({
    super.key,
    required this.trailing,
    this.backgroundColor = Colors.white,
  });

  final Widget trailing;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu, color: DriverTaskTokens.primary),
            onPressed: () {},
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'KECH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1,
                      color: DriverTaskTokens.primary,
                    ),
                  ),
                  Text(
                    'DELIVERY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      height: 1.1,
                      color: DriverTaskTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: trailing,
          ),
        ],
      ),
    );
  }
}

/// Online pill with pink border (alerts header mockup).
class DriverShellOnlinePill extends StatelessWidget {
  const DriverShellOnlinePill({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8C4C4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.4,
              color: DriverHomeTokens.primary,
            ),
          ),
        ],
      ),
    );
  }
}
