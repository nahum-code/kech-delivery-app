import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_home_tokens.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../../../shell/widgets/driver_shell_brand_header.dart';
import '../../widgets/driver_alert_check_updates_button.dart';
import '../../widgets/driver_alert_ripple_bell.dart';
import '../../widgets/driver_new_delivery_request_card.dart';

class DriverAlertScreen extends StatefulWidget {
  const DriverAlertScreen({super.key});

  @override
  State<DriverAlertScreen> createState() => DriverAlertScreenState();
}

class DriverAlertScreenState extends State<DriverAlertScreen> {
  bool get hasPendingRequest => _pending != null;

  DriverOrderSummary? _pending;
  DriverAvailability? _availability;
  bool _loading = true;
  bool _submitting = false;
  final Set<int> _dismissedIds = <int>{};

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() => _load();

  bool get _isOnline =>
      _availability?.operationalStatus == 'online' || _availability?.operationalStatus == 'busy';

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      final DriverOrderRepository repo = context.read<DriverOrderRepository>();
      final results = await Future.wait(<Future<Object?>>[
        repo.fetchAvailability(accessToken: token),
        repo.fetchOrders(accessToken: token),
      ]);
      if (!mounted) return;
      final DriverAvailability availability = results[0]! as DriverAvailability;
      final List<DriverOrderSummary> orders = results[1]! as List<DriverOrderSummary>;
      DriverOrderSummary? pending;
      for (final DriverOrderSummary o in orders) {
        if (o.needsAcknowledgment && !_dismissedIds.contains(o.id)) {
          pending = o;
          break;
        }
      }
      setState(() {
        _availability = availability;
        _pending = pending;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _accept() async {
    final DriverOrderSummary? order = _pending;
    if (order == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().accept(accessToken: token, orderId: order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted. Open Tasks to continue.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _decline() {
    final DriverOrderSummary? order = _pending;
    if (order == null) return;
    setState(() => _dismissedIds.add(order.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request dismissed. Contact dispatch if you cannot take this delivery.'),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DriverHomeTokens.screenBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DriverShellBrandHeader(
              trailing: DriverShellOnlinePill(isOnline: _availability != null && _isOnline),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: DriverTaskTokens.primary))
                  : RefreshIndicator(
                      color: DriverTaskTokens.primary,
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        children: <Widget>[
                          const Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: DriverTaskTokens.primary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _availability?.isOnline == true
                                ? 'New assignments appear here when sales assigns you an order.'
                                : 'Go online from Home to receive delivery requests.',
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: Color(0xFF8B6B6B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_pending != null)
                            DriverNewDeliveryRequestCard(
                              order: _pending!,
                              submitting: _submitting,
                              onAccept: _accept,
                              onDecline: _decline,
                            )
                          else ...<Widget>[
                            const SizedBox(height: 16),
                            const Center(child: DriverAlertRippleBell()),
                            const SizedBox(height: 32),
                            const Text(
                              'No new requests',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: DriverTaskTokens.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _availability?.isOnline == true
                                  ? 'You will be notified when a delivery is assigned to you.'
                                  : 'Turn on “Go online” on the Home tab.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: Color(0xFF8B6B6B),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Center(
                              child: DriverAlertCheckUpdatesButton(onPressed: _load),
                            ),
                          ],
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
