import 'package:flutter/material.dart';

import '../../../../shared/theme/driver_task_tokens.dart';

class DriverAlertCheckUpdatesButton extends StatelessWidget {
  const DriverAlertCheckUpdatesButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.sync, size: 20, color: DriverTaskTokens.primary),
              const SizedBox(width: 10),
              Text(
                'CHECK FOR UPDATES',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                  color: DriverTaskTokens.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
