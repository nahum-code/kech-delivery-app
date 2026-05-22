import 'dart:async';
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

/// How long the driver has to accept before the alert timer shows 0s.
const int kDriverAlertCountdownSeconds = 10;

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

  int? _countdownOrderId;
  DateTime? _countdownEndsAt;
  Timer? _countdownTimer;
  int _secondsLeft = kDriverAlertCountdownSeconds;

  @override
  void initState() {
    super.initState();
    _load(silent: false);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// [silent] keeps the alert sheet mounted during background polls (no timer reset).
  Future<void> reload({bool silent = true}) => _load(silent: silent);

  bool get _isOnline =>
      _availability?.operationalStatus == 'online' || _availability?.operationalStatus == 'busy';

  void _syncCountdown(DriverOrderSummary? pending) {
    _countdownTimer?.cancel();
    if (pending == null) {
      _countdownOrderId = null;
      _countdownEndsAt = null;
      _secondsLeft = kDriverAlertCountdownSeconds;
      return;
    }
    if (_countdownOrderId != pending.id) {
      _countdownOrderId = pending.id;
      _countdownEndsAt = DateTime.now().add(
        const Duration(seconds: kDriverAlertCountdownSeconds),
      );
    }

    void tick() {
      if (!mounted || _countdownEndsAt == null) return;
      final int left = _countdownEndsAt!.difference(DateTime.now()).inSeconds;
      setState(() => _secondsLeft = left.clamp(0, kDriverAlertCountdownSeconds));
      if (_secondsLeft <= 0) {
        _countdownTimer?.cancel();
      }
    }

    tick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
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
      _syncCountdown(pending);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await handleDriverApiError(context, e);
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
      _countdownTimer?.cancel();
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

  Future<void> _decline() async {
    final DriverOrderSummary? order = _pending;
    if (order == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final String token = context.read<AuthRepository>().currentSession!.accessToken;
      await context.read<DriverOrderRepository>().decline(accessToken: token, orderId: order.id);
      if (!mounted) return;
      _countdownTimer?.cancel();
      setState(() => _dismissedIds.add(order.id));
      showAppThemedSnackBar(
        context,
        message: 'Delivery declined. Dispatch has been notified.',
        tone: AppSnackTone.success,
      );
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      await handleDriverApiError(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showRequestSheet = _pending != null && !_loading;

    return ColoredBox(
      color: DriverHomeTokens.screenBackground,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DriverShellBrandHeader(
                  trailing: DriverShellOnlinePill(isOnline: _availability != null && _isOnline),
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: DriverTaskTokens.primary),
                        )
                      : RefreshIndicator(
                          color: DriverTaskTokens.primary,
                          onRefresh: () => _load(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(20, 8, 20, showRequestSheet ? 420 : 32),
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
                                  color: DriverAppTokens.emptySubtitle,
                                ),
                              ),
                              if (!showRequestSheet) ...<Widget>[
                                const SizedBox(height: 24),
                                const SizedBox(height: 16),
                                const Center(child: DriverAlertRippleBell()),
                                const SizedBox(height: 32),
                                const Text(
                                  'No new requests',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                    color: DriverTaskTokens.ink,
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
                                    color: DriverAppTokens.emptySubtitle,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Center(
                                  child: DriverAlertCheckUpdatesButton(
                                    onPressed: () => _load(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
            if (showRequestSheet) ...<Widget>[
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: DriverNewDeliveryRequestCard(
                    key: ValueKey<int>(_pending!.id),
                    order: _pending!,
                    secondsLeft: _secondsLeft,
                    submitting: _submitting,
                    onAccept: _accept,
                    onDecline: _decline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
