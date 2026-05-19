import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_profile_tokens.dart';
import 'customer_profile_account_tile.dart';

class CustomerProfilePreferencesGroup extends StatelessWidget {
  const CustomerProfilePreferencesGroup({
    super.key,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.onPushChanged,
    required this.onEmailChanged,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onEmailChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerProfileTokens.tileFill,
        borderRadius: BorderRadius.circular(CustomerProfileTokens.tileRadius),
      ),
      child: Column(
        children: <Widget>[
          _PreferenceRow(
            icon: Icons.notifications_outlined,
            title: 'Push notifications',
            value: pushEnabled,
            onChanged: onPushChanged,
          ),
          const Divider(height: 1, thickness: 1, color: CustomerProfileTokens.divider),
          _PreferenceRow(
            icon: Icons.mail_outline_rounded,
            title: 'Email updates',
            value: emailEnabled,
            onChanged: onEmailChanged,
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          CustomerProfileIconTile(icon: icon),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: CustomerProfileTokens.tileTitle)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: CustomerProfileTokens.primaryMaroon.withValues(alpha: 0.45),
            activeThumbColor: CustomerProfileTokens.primaryMaroon,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: CustomerProfileTokens.chevronGray.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
