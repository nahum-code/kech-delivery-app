import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
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
    return ColoredBox(
      color: DriverAppTokens.screenBackground,
      child: SafeArea(
        child: RefreshIndicator(
          color: DriverTaskTokens.primary,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DriverAppTokens.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your recent successful deliveries',
                style: TextStyle(color: DriverAppTokens.bodyGray),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: DriverTaskTokens.primary),
                )
              else if (_completed.isEmpty)
                const Text(
                  'No completed deliveries yet',
                  style: TextStyle(color: DriverAppTokens.bodyGray),
                )
              else
                ..._completed.map(
                  (DriverOrderSummary o) => Card(
                    color: DriverTaskTokens.card,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DriverTaskTokens.cardRadius),
                      side: const BorderSide(color: DriverTaskTokens.divider),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: DriverTaskTokens.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check, color: DriverAppTokens.onPrimary),
                      ),
                      title: Text(
                        o.restaurantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: DriverAppTokens.ink,
                        ),
                      ),
                      subtitle: Text(
                        'Delivered · ${o.reference}',
                        style: const TextStyle(color: DriverAppTokens.bodyGray),
                      ),
                      trailing: Text(
                        '${o.totalAmount} ETB',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: DriverTaskTokens.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
