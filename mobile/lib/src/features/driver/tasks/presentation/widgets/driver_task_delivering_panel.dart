import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../screens/driver_task_detail_screen.dart';
import 'driver_tasks_tab_empty_state.dart';

/// Out-for-delivery phase — mark delivered.
class DriverTaskDeliveringPanel extends StatefulWidget {
  const DriverTaskDeliveringPanel({
    super.key,
    required this.orders,
    required this.onChanged,
    this.onCheckUpdates,
  });

  final List<DriverOrderSummary> orders;
  final VoidCallback onChanged;
  final VoidCallback? onCheckUpdates;

  @override
  State<DriverTaskDeliveringPanel> createState() => _DriverTaskDeliveringPanelState();
}

class _DriverTaskDeliveringPanelState extends State<DriverTaskDeliveringPanel> {
  int? _actingOnId;

  Future<void> _complete(DriverOrderSummary order) async {
    setState(() => _actingOnId = order.id);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().complete(accessToken: token, orderId: order.id);
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return DriverTasksTabEmptyState(
        title: 'No deliveries in progress',
        subtitle: 'Pick up an order from the Pickup tab to start delivering.',
        onCheckUpdates: widget.onCheckUpdates,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: widget.orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final DriverOrderSummary o = widget.orders[index];
        final bool busy = _actingOnId == o.id;
        return Material(
          color: DriverTaskTokens.card,
          borderRadius: BorderRadius.circular(DriverTaskTokens.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(DriverTaskTokens.cardRadius),
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => DriverTaskDetailScreen(orderId: o.id)),
              );
              widget.onChanged();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.navigation_outlined, size: 40, color: DriverTaskTokens.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'DELIVER TO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: DriverTaskTokens.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.dropoffLine.isNotEmpty ? o.dropoffLine : o.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  Text('${o.restaurantName} · ${o.reference}', style: const TextStyle(color: DriverTaskTokens.bodyGray)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: busy ? null : () => _complete(o),
                    style: FilledButton.styleFrom(
                      backgroundColor: DriverTaskTokens.primary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('MARK AS DELIVERED', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
