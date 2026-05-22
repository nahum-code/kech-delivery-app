import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../core/http/api_error_message.dart';
import '../../../../../shared/theme/driver_home_tokens.dart';
import '../../../../../shared/widgets/driver/driver_inline_error.dart';
import '../../../shared/driver_session_handler.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../../../shell/widgets/driver_online_status_badge.dart';
import '../widgets/driver_dashed_rounded_box.dart';

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
        _error = userMessageFrom(e, fallback: 'Could not load home.');
        _loading = false;
      });
      if (isSessionExpiredError(e)) {
        handleDriverApiError(context, e);
      }
    }
  }

  bool get _isOnline =>
      _availability?.operationalStatus == 'online' || _availability?.operationalStatus == 'busy';

  bool get _switchOn =>
      _availability?.operationalStatus == 'online' || _availability?.operationalStatus == 'busy';

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
    return ColoredBox(
      color: DriverHomeTokens.screenBackground,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: DriverHomeTokens.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Kech Delivery',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: DriverHomeTokens.primary,
                      height: 1.1,
                    ),
                  ),
                  if (_availability != null) DriverOnlineStatusBadge(isOnline: _isOnline),
                ],
              ),
              const SizedBox(height: 20),
              _OnlineToggleCard(
                value: _switchOn,
                enabled: _availability?.operationalStatus != 'busy',
                onChanged: _availability == null ? null : _toggleOnline,
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: DriverHomeTokens.primary),
                  ),
                )
              else if (_error != null)
                DriverInlineError(message: _error!, onRetry: _load)
              else ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _HomeStatCard(label: 'ACTIVE', value: '${_active.length}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HomeStatCard(
                        label: 'STATUS',
                        value: (_availability?.operationalStatus ?? 'offline').toUpperCase(),
                        valueFontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'ACTIVE DELIVERIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: DriverHomeTokens.labelMuted,
                  ),
                ),
                const SizedBox(height: 12),
                if (_active.isEmpty)
                  DriverDashedRoundedBox(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: DriverHomeTokens.emptyIconBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 28,
                            color: DriverHomeTokens.labelMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No active deliveries.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: DriverHomeTokens.emptyBody,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'New assignments appear under Alerts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: DriverHomeTokens.emptyBody,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._active.take(5).map(
                        (DriverOrderSummary o) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ActiveDeliveryTile(order: o),
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineToggleCard extends StatelessWidget {
  const _OnlineToggleCard({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        color: DriverHomeTokens.primary,
        borderRadius: BorderRadius.circular(DriverHomeTokens.onlineCardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x1A800020), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Go online for deliveries',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You must be online to receive new assignments',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeTrackColor: DriverHomeTokens.toggleTrackOn,
            activeThumbColor: DriverHomeTokens.toggleThumbOn,
            inactiveTrackColor: Colors.white24,
            inactiveThumbColor: Colors.white,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({
    required this.label,
    required this.value,
    this.valueFontSize = 28,
  });

  final String label;
  final String value;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: DriverHomeTokens.cardSurface,
        borderRadius: BorderRadius.circular(DriverHomeTokens.statCardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: DriverHomeTokens.labelMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              color: DriverHomeTokens.primary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveDeliveryTile extends StatelessWidget {
  const _ActiveDeliveryTile({required this.order});

  final DriverOrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverHomeTokens.cardSurface,
        borderRadius: BorderRadius.circular(DriverHomeTokens.statCardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.reference,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: DriverHomeTokens.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.restaurantName} · ${order.status}',
                  style: const TextStyle(color: DriverHomeTokens.emptyBody, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '${order.totalAmount} ETB',
            style: const TextStyle(fontWeight: FontWeight.w700, color: DriverHomeTokens.primary),
          ),
        ],
      ),
    );
  }
}
