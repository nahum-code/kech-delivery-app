import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../shared/driver_session_handler.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../screens/driver_task_detail_screen.dart';
import '../../../../../shared/widgets/map/location_map_preview.dart';
import 'driver_task_map_placeholder.dart';
import 'driver_tasks_tab_empty_state.dart';

/// Pickup phase — assigned / picked_up orders.
class DriverTaskPickupPanel extends StatefulWidget {
  const DriverTaskPickupPanel({
    super.key,
    required this.orders,
    required this.onChanged,
    this.onCheckUpdates,
  });

  final List<DriverOrderSummary> orders;
  final VoidCallback onChanged;
  final VoidCallback? onCheckUpdates;

  @override
  State<DriverTaskPickupPanel> createState() => _DriverTaskPickupPanelState();
}

class _DriverTaskPickupPanelState extends State<DriverTaskPickupPanel> {
  int? _actingOnId;

  Future<void> _pickup(DriverOrderSummary order) async {
    setState(() => _actingOnId = order.id);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().pickup(accessToken: token, orderId: order.id);
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      await handleDriverApiError(context, e);
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  Future<void> _startDelivery(DriverOrderSummary order) async {
    setState(() => _actingOnId = order.id);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().startDelivery(accessToken: token, orderId: order.id);
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      await handleDriverApiError(context, e);
    } finally {
      if (mounted) setState(() => _actingOnId = null);
    }
  }

  static ButtonStyle get _primaryButtonStyle => FilledButton.styleFrom(
        backgroundColor: DriverTaskTokens.primary,
        foregroundColor: DriverTaskTokens.onPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.orders.isEmpty) {
      return DriverTasksTabEmptyState(
        title: 'No pickups right now',
        subtitle: 'Accept a request from Alerts or wait for assignment.',
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
                  DriverTaskMapPlaceholder(
                    label: o.restaurantName,
                    latitude: o.restaurantLatitude,
                    longitude: o.restaurantLongitude,
                    markerRole: MapPreviewMarkerRole.pickup,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PICKUP FROM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: DriverTaskTokens.muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: DriverTaskTokens.ink,
                    ),
                  ),
                  if (o.restaurantAddress.isNotEmpty)
                    Text(
                      o.restaurantAddress,
                      style: const TextStyle(color: DriverTaskTokens.bodyGray),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    o.reference,
                    style: const TextStyle(
                      color: DriverTaskTokens.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (o.status == 'assigned')
                    FilledButton(
                      onPressed: busy ? null : () => _pickup(o),
                      style: _primaryButtonStyle,
                      child: busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DriverTaskTokens.onPrimary,
                              ),
                            )
                          : const Text('MARK AS PICKED UP', style: TextStyle(fontWeight: FontWeight.w800)),
                    )
                  else if (o.status == 'picked_up')
                    FilledButton(
                      onPressed: busy ? null : () => _startDelivery(o),
                      style: _primaryButtonStyle,
                      child: const Text('START DELIVERY', style: TextStyle(fontWeight: FontWeight.w800)),
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
