import 'package:flutter/material.dart';

import '../../../../shared/contracts/driver_main_tab.dart';
import '../../../../shared/theme/driver_shell_navigation_tokens.dart';

class DriverMainBottomNavBar extends StatelessWidget {
  const DriverMainBottomNavBar({
    super.key,
    required this.current,
    required this.onTabSelected,
  });

  final DriverMainTab current;
  final ValueChanged<DriverMainTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: DriverShellNavigationTokens.bottomBarSurface,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
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
                    label: 'HOME',
                    selected: current == DriverMainTab.home,
                    onTap: () => onTabSelected(DriverMainTab.home),
                  ),
                ),
                Expanded(
                  child: _NavTile(
                    icon: Icons.assignment_outlined,
                    label: 'TASKS',
                    selected: current == DriverMainTab.tasks,
                    onTap: () => onTabSelected(DriverMainTab.tasks),
                  ),
                ),
                Expanded(
                  child: _NavTile(
                    icon: Icons.history,
                    label: 'ACTIVITY',
                    selected: current == DriverMainTab.activity,
                    onTap: () => onTabSelected(DriverMainTab.activity),
                  ),
                ),
                Expanded(
                  child: _NavTile(
                    icon: Icons.person_outline_rounded,
                    label: 'PROFILE',
                    selected: current == DriverMainTab.profile,
                    onTap: () => onTabSelected(DriverMainTab.profile),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? DriverShellNavigationTokens.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: selected ? DriverShellNavigationTokens.primary : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
