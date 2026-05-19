import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_profile_tokens.dart';

class CustomerProfileAccountTile extends StatelessWidget {
  const CustomerProfileAccountTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: CustomerProfileTokens.tileFill,
        borderRadius: BorderRadius.circular(CustomerProfileTokens.tileRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(CustomerProfileTokens.tileRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IconTile(icon: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: CustomerProfileTokens.tileTitle),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 6),
                        subtitle!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: CustomerProfileTokens.chevronGray,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerProfileIconTile extends StatelessWidget {
  const CustomerProfileIconTile({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _IconTile(icon: icon);
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerProfileTokens.iconTileSurface,
        borderRadius: BorderRadius.circular(CustomerProfileTokens.iconTileRadius),
      ),
      child: SizedBox(
        width: CustomerProfileTokens.iconTileSize,
        height: CustomerProfileTokens.iconTileSize,
        child: Icon(icon, color: CustomerProfileTokens.primaryMaroon, size: 22),
      ),
    );
  }
}

class CustomerProfileAddressTags extends StatelessWidget {
  const CustomerProfileAddressTags({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CustomerProfileTag(label: 'HOME', background: CustomerProfileTokens.homeChipFill, foreground: CustomerProfileTokens.homeChipText),
        const SizedBox(width: 6),
        CustomerProfileTag(label: 'WORK', background: CustomerProfileTokens.workChipFill, foreground: CustomerProfileTokens.workChipText),
      ],
    );
  }
}

class CustomerProfileTag extends StatelessWidget {
  const CustomerProfileTag({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
