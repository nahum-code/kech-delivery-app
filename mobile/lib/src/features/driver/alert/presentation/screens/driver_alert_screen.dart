import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../../../shared/widgets/app_themed_snackbar.dart';
import '../../../shared/driver_session_handler.dart';
import '../../../../../shared/theme/driver_home_tokens.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../../../shell/widgets/driver_shell_brand_header.dart';
import '../../widgets/driver_alert_check_updates_button.dart';
import '../../widgets/driver_alert_ripple_bell.dart';
import '../../widgets/driver_new_delivery_request_card.dart';
import 'driver_broadcast_offer_detail_screen.dart';

/// Driver alerts: combines (a) manual-assignment acknowledgements and
/// (b) the broadcast feed of orders any approved+online driver can claim
/// on a first-come-first-serve basis.
class DriverAlertScreen extends StatefulWidget {
  const DriverAlertScreen({super.key});

  @override
  State<DriverAlertScreen> createState() => DriverAlertScreenState();
}

class DriverAlertScreenState extends State<DriverAlertScreen> {
  bool get hasPendingRequest => _pending != null || _visibleAvailable.isNotEmpty;

  DriverOrderSummary? _pending;
  List<DriverOrderSummary> _available = const <DriverOrderSummary>[];
  final Set<int> _claiming = <int>{};
  DriverAvailability? _availability;
  bool _loading = true;
  bool _submitting = false;
  final Set<int> _dismissedIds = <int>{};
  // Broadcast offers the driver tapped "Skip" on. Client-side only —
  // resets on app relaunch and never leaves the device. Other drivers
  // still see these orders, and admin/sales can still manually assign.
  final Set<int> _skippedAvailableIds = <int>{};

  List<DriverOrderSummary> get _visibleAvailable =>
      _available.where((DriverOrderSummary o) => !_skippedAvailableIds.contains(o.id)).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _load(silent: false); // first mount: show spinner
  }

  /// Refresh used by the shell's periodic poll (silent, default) and tab
  /// taps (`silent: false` → shows spinner).
  Future<void> reload({bool silent = true}) => _load(silent: silent);

  bool get _isOnline =>
      _availability?.operationalStatus == 'online' || _availability?.operationalStatus == 'busy';

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      final DriverOrderRepository repo = context.read<DriverOrderRepository>();
      final results = await Future.wait(<Future<Object?>>[
        repo.fetchAvailability(accessToken: token),
        repo.fetchOrders(accessToken: token),
        repo.fetchAvailable(accessToken: token),
      ]);
      if (!mounted) return;
      final DriverAvailability availability = results[0]! as DriverAvailability;
      final List<DriverOrderSummary> orders = results[1]! as List<DriverOrderSummary>;
      final List<DriverOrderSummary> available = results[2]! as List<DriverOrderSummary>;
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
        _available = available;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _claim(DriverOrderSummary order) async {
    if (_claiming.contains(order.id)) return;
    setState(() => _claiming.add(order.id));
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().claim(accessToken: token, orderId: order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Got it. Order ${order.reference} is yours — open Tasks.')),
      );
      await _load(silent: true);
    } on OrderTakenException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Too slow — another driver got it.')),
      );
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      final String raw = e.toString().replaceFirst('Exception: ', '');
      final String message = _friendlyClaimError(raw);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _claiming.remove(order.id));
    }
  }

  String _friendlyClaimError(String raw) {
    // Replace the backend's plain "Driver already has N active deliveries."
    // with a softer, action-oriented hint.
    final RegExp atCap = RegExp(r"already has (\d+) active deliveries", caseSensitive: false);
    final Match? match = atCap.firstMatch(raw);
    if (match != null) {
      return "You're already at ${match.group(1)} active deliveries — finish one before taking another.";
    }
    return raw;
  }

  Future<void> _decline() async {
    final DriverOrderSummary? order = _pending;
    if (order == null) return;
    setState(() => _dismissedIds.add(order.id));
    // Tell the backend so the order's status moves to `declined` and
    // admin/sales can reassign — without this the order stays attached
    // to this driver as `assigned`.
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().decline(
            accessToken: token,
            orderId: order.id,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery declined. Dispatch will reassign.'),
      ),
    );
    await _load(silent: true);
  }

  Future<void> _openDetail(DriverOrderSummary order) async {
    final BroadcastOfferAction? choice = await Navigator.of(context).push<BroadcastOfferAction>(
      MaterialPageRoute<BroadcastOfferAction>(
        builder: (_) => DriverBroadcastOfferDetailScreen(
          orderId: order.id,
          reference: order.reference,
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == BroadcastOfferAction.accept) {
      await _claim(order);
    } else {
      _skip(order);
    }
  }

  void _skip(DriverOrderSummary order) {
    setState(() => _skippedAvailableIds.add(order.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skipped ${order.reference}. Another driver may still take it.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DriverOrderSummary> visibleAvailable = _visibleAvailable;
    final bool nothingToShow = _pending == null && visibleAvailable.isEmpty;
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
                      onRefresh: () => _load(silent: true),
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
                                ? 'New assignments and open requests appear here.'
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
                            ),
                          if (visibleAvailable.isNotEmpty) ...<Widget>[
                            if (_pending != null) const SizedBox(height: 20),
                            const Text(
                              'OPEN REQUESTS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: DriverTaskTokens.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'First driver to accept gets the delivery.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF8B6B6B)),
                            ),
                            const SizedBox(height: 12),
                            for (final DriverOrderSummary o in visibleAvailable)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _BroadcastOfferCard(
                                  order: o,
                                  submitting: _claiming.contains(o.id),
                                  enabled: _isOnline,
                                  onAccept: () => _claim(o),
                                  onSkip: () => _skip(o),
                                  onDetail: () => _openDetail(o),
                                ),
                              ),
                          ],
                          if (nothingToShow) ...<Widget>[
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
                                  ? 'You will be notified when a delivery is offered.'
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
                              child: DriverAlertCheckUpdatesButton(onPressed: () => _load(silent: false)),
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

class _BroadcastOfferCard extends StatelessWidget {
  const _BroadcastOfferCard({
    required this.order,
    required this.submitting,
    required this.enabled,
    required this.onAccept,
    required this.onSkip,
    required this.onDetail,
  });

  final DriverOrderSummary order;
  final bool submitting;
  final bool enabled;
  final VoidCallback onAccept;
  final VoidCallback onSkip;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6D8DA)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  order.restaurantName.isEmpty ? 'Restaurant' : order.restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: DriverTaskTokens.primary,
                  ),
                ),
              ),
              Text(
                '${order.driverPayout} ETB',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: DriverTaskTokens.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '#${order.reference} · ${order.customerName}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8B6B6B)),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF8B6B6B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.restaurantAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5C4A4A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8B6B6B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.dropoffLine.isEmpty ? '—' : order.dropoffLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF5C4A4A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: submitting ? null : onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DriverTaskTokens.primary,
                    minimumSize: const Size.fromHeight(40),
                    side: const BorderSide(color: Color(0xFFE6D8DA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: submitting ? null : onDetail,
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Detail'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DriverTaskTokens.primary,
                    minimumSize: const Size.fromHeight(40),
                    side: const BorderSide(color: Color(0xFFE6D8DA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: !enabled || submitting ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: DriverTaskTokens.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(enabled ? 'Accept' : 'Go online'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
