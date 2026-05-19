import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_shell_navigation_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';

class DriverHomeTabScreen extends StatefulWidget {
  const DriverHomeTabScreen({super.key});

  @override
  State<DriverHomeTabScreen> createState() => _DriverHomeTabScreenState();
}

class _DriverHomeTabScreenState extends State<DriverHomeTabScreen> {
  DriverAvailability? _availability;
  List<DriverOrderSummary> _active = <DriverOrderSummary>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      final DriverOrderRepository repo = context.read<DriverOrderRepository>();
      final results = await Future.wait(<Future<Object?>>[
        repo.fetchAvailability(accessToken: token),
        repo.fetchOrders(accessToken: token),
      ]);
      if (!mounted) return;
      setState(() {
        _availability = results[0]! as DriverAvailability;
        _active = (results[1]! as List<DriverOrderSummary>).where((o) => o.isActive).toList();
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

  Future<void> _toggleOnline(bool value) async {
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      final DriverAvailability next = await context.read<DriverOrderRepository>().setOnline(
            accessToken: token,
            online: value,
          );
      if (!mounted) return;
      setState(() => _availability = next);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: DriverShellNavigationTokens.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Kech Delivery',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (_availability != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _availability!.isOnline
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _availability!.isOnline ? '• ONLINE' : '• OFFLINE',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _availability!.isOnline
                            ? const Color(0xFF065F46)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: SwitchListTile(
                title: const Text('Go online for deliveries'),
                subtitle: const Text('You must be online to receive assignments'),
                value: _availability?.operationalStatus == 'online' ||
                    _availability?.operationalStatus == 'busy',
                onChanged: _availability?.operationalStatus == 'busy'
                    ? null
                    : (bool v) => _toggleOnline(v),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_error != null)
              Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            else ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      label: 'ACTIVE',
                      value: '${_active.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'STATUS',
                      value: (_availability?.operationalStatus ?? 'offline').toUpperCase(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Active deliveries', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_active.isEmpty)
                const Text('No active deliveries. Check Tasks when assigned.')
              else
                ..._active.take(3).map(
                      (DriverOrderSummary o) => ListTile(
                        title: Text(o.reference),
                        subtitle: Text('${o.restaurantName} · ${o.status}'),
                        trailing: Text('${o.totalAmount} MAD'),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
