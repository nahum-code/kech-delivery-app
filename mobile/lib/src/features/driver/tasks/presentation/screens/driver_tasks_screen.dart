import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_shell_navigation_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import 'driver_task_detail_screen.dart';

class DriverTasksScreen extends StatefulWidget {
  const DriverTasksScreen({super.key});

  @override
  State<DriverTasksScreen> createState() => DriverTasksScreenState();
}

class DriverTasksScreenState extends State<DriverTasksScreen> {
  List<DriverOrderSummary> _orders = <DriverOrderSummary>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      final List<DriverOrderSummary> all =
          await context.read<DriverOrderRepository>().fetchOrders(accessToken: token);
      if (!mounted) return;
      setState(() {
        _orders = all.where((DriverOrderSummary o) => o.isActive).toList();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Tasks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: DriverShellNavigationTokens.primary,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(child: Text(_error!)),
                            ),
                          ],
                        )
                      : _orders.isEmpty
                          ? ListView(
                              children: const <Widget>[
                                SizedBox(height: 80),
                                Center(child: Text('No active tasks')),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _orders.length,
                              itemBuilder: (BuildContext context, int index) {
                                final DriverOrderSummary o = _orders[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(o.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${o.restaurantName}\n${o.customerName}'),
                                    isThreeLine: true,
                                    trailing: _StatusChip(status: o.status),
                                    onTap: () async {
                                      await Navigator.of(context).push<void>(
                                        MaterialPageRoute<void>(
                                          builder: (_) => DriverTaskDetailScreen(orderId: o.id),
                                        ),
                                      );
                                      await _load();
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DriverShellNavigationTokens.primary),
      ),
    );
  }
}
