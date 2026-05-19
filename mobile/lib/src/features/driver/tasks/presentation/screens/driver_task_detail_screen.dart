import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_shell_navigation_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';

/// Pickup + delivery workflow for a single assigned order (MVP manual assign).
class DriverTaskDetailScreen extends StatefulWidget {
  const DriverTaskDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<DriverTaskDetailScreen> createState() => _DriverTaskDetailScreenState();
}

class _DriverTaskDetailScreenState extends State<DriverTaskDetailScreen> {
  DriverOrderDetail? _order;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _token => context.read<AuthRepository>().currentSession!.accessToken;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final DriverOrderDetail detail = await context.read<DriverOrderRepository>().fetchOrderDetail(
            accessToken: _token,
            orderId: widget.orderId,
          );
      if (!mounted) return;
      setState(() {
        _order = detail;
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

  Future<void> _run(Future<DriverOrderDetail> Function() action) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final DriverOrderDetail updated = await action();
      if (!mounted) return;
      setState(() {
        _order = updated;
        _submitting = false;
      });
      if (updated.status == 'delivered') {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final DriverOrderDetail? order = _order;
    return Scaffold(
      backgroundColor: DriverShellNavigationTokens.screenBackground,
      appBar: AppBar(
        backgroundColor: DriverShellNavigationTokens.primary,
        foregroundColor: Colors.white,
        title: Text(order?.reference ?? 'Delivery'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : order == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _MapPlaceholder(label: order.restaurantName),
                          const SizedBox(height: 16),
                          _InfoCard(
                            label: 'PICKUP FROM',
                            title: order.restaurantName,
                            subtitle: order.restaurantAddress,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _InfoCard(
                                  label: 'ITEMS',
                                  title: '${order.items.length} items',
                                  subtitle: '',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  label: 'CUSTOMER',
                                  title: order.deliveryAddress.receiverName,
                                  subtitle: order.customerPhone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoCard(
                            label: 'DROPOFF ADDRESS',
                            title: order.deliveryAddress.addressLine,
                            subtitle: order.deliveryAddress.landmark.isNotEmpty
                                ? order.deliveryAddress.landmark
                                : order.deliveryAddress.phone,
                          ),
                          const SizedBox(height: 24),
                          ..._actionButtons(order),
                        ],
                      ),
                    ),
    );
  }

  List<Widget> _actionButtons(DriverOrderDetail order) {
    final DriverOrderRepository repo = context.read<DriverOrderRepository>();
    final List<Widget> buttons = <Widget>[];

    if (order.status == 'assigned') {
      if (order.driverAcknowledgedAt == null) {
        buttons.add(_primaryButton(
          label: 'ACCEPT DELIVERY',
          onPressed: _submitting
              ? null
              : () => _run(() => repo.accept(accessToken: _token, orderId: order.id)),
        ));
        buttons.add(const SizedBox(height: 12));
      }
      buttons.add(_primaryButton(
        label: 'MARK AS PICKED UP',
        onPressed: _submitting
            ? null
            : () => _run(() => repo.pickup(accessToken: _token, orderId: order.id)),
      ));
    } else if (order.status == 'picked_up') {
      buttons.add(_primaryButton(
        label: 'START DELIVERY',
        onPressed: _submitting
            ? null
            : () => _run(() => repo.startDelivery(accessToken: _token, orderId: order.id)),
      ));
    } else if (order.status == 'delivering') {
      buttons.add(_primaryButton(
        label: 'MARK AS DELIVERED',
        onPressed: _submitting
            ? null
            : () => _run(() => repo.complete(accessToken: _token, orderId: order.id)),
      ));
    }

    return buttons;
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.map_outlined, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.title, required this.subtitle});

  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (subtitle.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _primaryButton({required String label, required VoidCallback? onPressed}) {
  return FilledButton.icon(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: DriverShellNavigationTokens.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    icon: const Icon(Icons.check_circle_outline),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
  );
}
