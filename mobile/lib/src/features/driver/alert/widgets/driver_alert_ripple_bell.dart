import 'package:flutter/material.dart';

import '../../../../shared/theme/driver_task_tokens.dart';

/// Bell icon with concentric ripple rings (alerts empty state).
class DriverAlertRippleBell extends StatelessWidget {
  const DriverAlertRippleBell({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _ring(140, const Color(0x14F5C4C4)),
          _ring(110, const Color(0x24F5C4C4)),
          _ring(84, const Color(0x33F5C4C4)),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: DriverTaskTokens.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 36,
              color: DriverTaskTokens.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
