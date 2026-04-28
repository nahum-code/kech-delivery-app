import 'package:flutter/material.dart';

import '../../../../../shared/contracts/customer_main_tab.dart';
import '../../../../../shared/theme/customer_shell_navigation_tokens.dart';

class CustomerMainBottomNavBar extends StatelessWidget {
  const CustomerMainBottomNavBar({
    super.key,
    required this.current,
    required this.onTabSelected,
    this.uppercaseLabels = false,
  });

  final CustomerMainTab current;
  final ValueChanged<CustomerMainTab> onTabSelected;
  final bool uppercaseLabels;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: CustomerShellNavigationTokens.bottomBarSurface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
            children: <Widget>[
              Expanded(
                child: _NavTile(
                  icon: Icons.home_outlined,
                  label: uppercaseLabels ? 'HOME' : 'Home',
                  selected: current == CustomerMainTab.home,
                  onTap: () => onTabSelected(CustomerMainTab.home),
                ),
              ),
              Expanded(
                child: _NavTile(
                  icon: Icons.receipt_long_outlined,
                  label: uppercaseLabels ? 'ORDERS' : 'Orders',
                  selected: current == CustomerMainTab.orders,
                  onTap: () => onTabSelected(CustomerMainTab.orders),
                ),
              ),
              Expanded(
                child: _NavTile(
                  icon: Icons.mail_outline_rounded,
                  label: uppercaseLabels ? 'INBOX' : 'Inbox',
                  selected: current == CustomerMainTab.inbox,
                  onTap: () => onTabSelected(CustomerMainTab.inbox),
                ),
              ),
              Expanded(
                child: _NavTile(
                  icon: Icons.person_outline_rounded,
                  label: uppercaseLabels ? 'PROFILE' : 'Profile',
                  selected: current == CustomerMainTab.profile,
                  onTap: () => onTabSelected(CustomerMainTab.profile),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = selected ? Colors.white : CustomerShellNavigationTokens.inactiveNavGray;
    final Color textColor = selected ? CustomerShellNavigationTokens.primaryMaroon : CustomerShellNavigationTokens.inactiveNavGray;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CustomerShellNavigationTokens.bottomNavRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? CustomerShellNavigationTokens.primaryMaroon : Colors.transparent,
                borderRadius: BorderRadius.circular(CustomerShellNavigationTokens.bottomNavRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
