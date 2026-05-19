import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';

class DriverActivityScreen extends StatefulWidget {
  const DriverActivityScreen({super.key});

  @override
  State<DriverActivityScreen> createState() => _DriverActivityScreenState();
}

class _DriverActivityScreenState extends State<DriverActivityScreen> {
  List<DriverOrderSummary> _completed = <DriverOrderSummary>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final String token = context.read<AuthRepository>().currentSession!.accessToken;
    final List<DriverOrderSummary> all =
        await context.read<DriverOrderRepository>().fetchOrders(
              accessToken: token,
              status: 'delivered',
            );
    if (!mounted) return;
    setState(() {
      _completed = all;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const Text('Activity', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Your recent successful deliveries',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_completed.isEmpty)
              const Text('No completed deliveries yet')
            else
              ..._completed.map(
                (DriverOrderSummary o) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF800020),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(o.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Delivered · ${o.reference}'),
                    trailing: Text('${o.totalAmount} MAD', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
