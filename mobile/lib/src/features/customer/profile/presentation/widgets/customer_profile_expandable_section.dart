import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_profile_tokens.dart';
import 'customer_profile_account_tile.dart';

/// Expandable account row — tap header to show detail panel.
class CustomerProfileExpandableSection extends StatefulWidget {
  const CustomerProfileExpandableSection({
    super.key,
    required this.icon,
    required this.title,
    this.collapsedSummary,
    this.children = const <Widget>[],
  });

  final IconData icon;
  final String title;
  final Widget? collapsedSummary;
  final List<Widget> children;

  @override
  State<CustomerProfileExpandableSection> createState() => _CustomerProfileExpandableSectionState();
}

class _CustomerProfileExpandableSectionState extends State<CustomerProfileExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: CustomerProfileTokens.tileFill,
        borderRadius: BorderRadius.circular(CustomerProfileTokens.tileRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(CustomerProfileTokens.tileRadius),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomerProfileIconTile(icon: widget.icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.title, style: CustomerProfileTokens.tileTitle),
                          if (!_expanded && widget.collapsedSummary != null) ...<Widget>[
                            const SizedBox(height: 6),
                            widget.collapsedSummary!,
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: CustomerProfileTokens.chevronGray,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 52, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children,
                    ),
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerProfileInfoRow extends StatelessWidget {
  const CustomerProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget row = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: CustomerProfileTokens.primaryMaroon),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: CustomerProfileTokens.subtitleGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: CustomerProfileTokens.titleInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
    if (onTap == null) {
      return row;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}

class CustomerProfileAddressEntryRow extends StatelessWidget {
  const CustomerProfileAddressEntryRow({
    super.key,
    required this.label,
    required this.addressLine,
    required this.chipBackground,
    required this.chipForeground,
  });

  final String label;
  final String addressLine;
  final Color chipBackground;
  final Color chipForeground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomerProfileTag(
            label: label,
            background: chipBackground,
            foreground: chipForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              addressLine,
              style: const TextStyle(
                color: CustomerProfileTokens.titleInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
