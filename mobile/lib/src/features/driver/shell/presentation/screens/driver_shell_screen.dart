import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../shared/contracts/driver_main_tab.dart';
import '../../../../../shared/theme/driver_shell_navigation_tokens.dart';
import '../../../alert/presentation/screens/driver_alert_screen.dart';
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
  final GlobalKey<DriverAlertScreenState> _alertKey = GlobalKey<DriverAlertScreenState>();
  Timer? _pollTimer;
  bool _hasPendingAlert = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) => _refreshAlertBadge());
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAlertBadge());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _onTabSelected(DriverMainTab tab) {
    setState(() => _tab = tab);
    if (tab == DriverMainTab.tasks) {
      _tasksKey.currentState?.refresh();
    } else if (tab == DriverMainTab.alert) {
      _alertKey.currentState?.reload();
    }
  }

  Future<void> _refreshAlertBadge() async {
    await _alertKey.currentState?.reload();
    if (!mounted) return;
    final bool pending = _alertKey.currentState?.hasPendingRequest ?? false;
    if (pending != _hasPendingAlert) {
      setState(() => _hasPendingAlert = pending);
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
          DriverAlertScreen(key: _alertKey),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: DriverMainBottomNavBar(
        current: _tab,
        alertBadge: _hasPendingAlert,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
