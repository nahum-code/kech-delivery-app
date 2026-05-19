import 'package:flutter/material.dart';

import '../../../../../shared/contracts/driver_main_tab.dart';
import '../../../../../shared/theme/driver_shell_navigation_tokens.dart';
import '../../../activity/presentation/screens/driver_activity_screen.dart';
import '../../../home/presentation/screens/driver_home_tab_screen.dart';
import '../../../profile/presentation/screens/driver_profile_screen.dart';
import '../../../tasks/presentation/screens/driver_tasks_screen.dart';
import '../../widgets/driver_main_bottom_nav_bar.dart';

class DriverShellScreen extends StatefulWidget {
  const DriverShellScreen({super.key});

  @override
  State<DriverShellScreen> createState() => _DriverShellScreenState();
}

class _DriverShellScreenState extends State<DriverShellScreen> {
  DriverMainTab _tab = DriverMainTab.home;
  final GlobalKey<DriverTasksScreenState> _tasksKey = GlobalKey<DriverTasksScreenState>();

  void _onTabSelected(DriverMainTab tab) {
    setState(() => _tab = tab);
    if (tab == DriverMainTab.tasks) {
      _tasksKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverShellNavigationTokens.screenBackground,
      body: IndexedStack(
        index: _tab.index,
        children: <Widget>[
          const DriverHomeTabScreen(),
          DriverTasksScreen(key: _tasksKey),
          const DriverActivityScreen(),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: DriverMainBottomNavBar(
        current: _tab,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
