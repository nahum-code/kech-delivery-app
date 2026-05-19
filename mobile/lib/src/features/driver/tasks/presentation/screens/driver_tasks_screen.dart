import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_home_tokens.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../../../shell/widgets/driver_online_status_badge.dart';
import '../widgets/driver_task_activity_panel.dart';
import '../widgets/driver_task_delivering_panel.dart';
import '../widgets/driver_task_pickup_panel.dart';

class DriverTasksScreen extends StatefulWidget {
  const DriverTasksScreen({super.key});

  @override
  State<DriverTasksScreen> createState() => DriverTasksScreenState();
}

class DriverTasksScreenState extends State<DriverTasksScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<DriverOrderSummary> _all = <DriverOrderSummary>[];
  DriverAvailability? _availability;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refresh() => _load();

  bool get _isOnline =>
      _availability?.operationalStatus == 'online' || _availability?.operationalStatus == 'busy';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      final DriverOrderRepository repo = context.read<DriverOrderRepository>();
      final results = await Future.wait(<Future<Object?>>[
        repo.fetchOrders(accessToken: token),
        repo.fetchAvailability(accessToken: token),
      ]);
      if (!mounted) return;
      setState(() {
        _all = results[0]! as List<DriverOrderSummary>;
        _availability = results[1]! as DriverAvailability;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<DriverOrderSummary> get _pickupOrders =>
      _all.where((DriverOrderSummary o) => o.isPickupPhase && !o.needsAcknowledgment).toList();

  List<DriverOrderSummary> get _deliveringOrders =>
      _all.where((DriverOrderSummary o) => o.isDeliveringPhase).toList();

  List<DriverOrderSummary> get _completedOrders =>
      _all.where((DriverOrderSummary o) => o.status == 'delivered').toList();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DriverHomeTokens.screenBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.menu, color: DriverTaskTokens.primary),
                    onPressed: () {},
                  ),
                  const Expanded(
                    child: Text(
                      'TASKS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: DriverTaskTokens.primary,
                      ),
                    ),
                  ),
                  if (_availability != null)
                    DriverOnlineStatusBadge(isOnline: _isOnline)
                  else
                    const SizedBox(width: 72),
                ],
              ),
            ),
            Material(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: DriverTaskTokens.primary,
                unselectedLabelColor: DriverTaskTokens.tabInactive,
                indicatorColor: DriverTaskTokens.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: const Color(0xFFF0E8E8),
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.8),
                tabs: const <Tab>[
                  Tab(text: 'PICKUP'),
                  Tab(text: 'DELIVER'),
                  Tab(text: 'ACTIVITY'),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: DriverTaskTokens.primary))
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_error!, textAlign: TextAlign.center),
                          ),
                        )
                      : RefreshIndicator(
                          color: DriverTaskTokens.primary,
                          onRefresh: _load,
                          child: TabBarView(
                            controller: _tabController,
                            children: <Widget>[
                              DriverTaskPickupPanel(
                                orders: _pickupOrders,
                                onChanged: _load,
                                onCheckUpdates: _load,
                              ),
                              DriverTaskDeliveringPanel(
                                orders: _deliveringOrders,
                                onChanged: _load,
                                onCheckUpdates: _load,
                              ),
                              DriverTaskActivityPanel(
                                orders: _completedOrders,
                                onCheckUpdates: _load,
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
