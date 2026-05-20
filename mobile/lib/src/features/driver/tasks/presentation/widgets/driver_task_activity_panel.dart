import 'package:flutter/material.dart';

import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../orders/domain/driver_order_models.dart';
import 'driver_tasks_tab_empty_state.dart';

/// Completed deliveries inside Tasks tab.
class DriverTaskActivityPanel extends StatelessWidget {
  const DriverTaskActivityPanel({super.key, required this.orders, this.onCheckUpdates});

  final List<DriverOrderSummary> orders;
  final VoidCallback? onCheckUpdates;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return DriverTasksTabEmptyState(
        title: 'No activity yet',
        subtitle: 'Completed deliveries will show up here.',
        onCheckUpdates: onCheckUpdates,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final DriverOrderSummary o = orders[index];
        return Material(
          color: DriverTaskTokens.card,
          borderRadius: BorderRadius.circular(DriverTaskTokens.cardRadius),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DriverTaskTokens.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check, color: Colors.white),
            ),
            title: Text(o.restaurantName, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('Delivered · ${o.reference}'),
            trailing: Text('${o.totalAmount} ETB', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        );
      },
    );
  }
}
