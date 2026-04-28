import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeSectionHeader extends StatelessWidget {
  const CustomerHomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: CustomerHomeTokens.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: CustomerHomeTokens.mutedCaption,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onActionPressed,
          style: TextButton.styleFrom(
            foregroundColor: CustomerHomeTokens.primaryMaroon,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            padding: const EdgeInsets.only(left: 8, top: 0, bottom: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(actionLabel),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}
