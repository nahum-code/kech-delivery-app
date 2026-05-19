import 'package:flutter/material.dart';

import '../../../../../shared/theme/driver_profile_tokens.dart';

class DriverProfileSettingsTile extends StatelessWidget {
  const DriverProfileSettingsTile({
    super.key,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DriverProfileTokens.cardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DriverProfileTokens.cardSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: DriverProfileTokens.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1F2937)),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: DriverProfileTokens.primary,
            activeThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFF5D0D0),
            inactiveThumbColor: Colors.white,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
