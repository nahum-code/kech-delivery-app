import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../orders/data/order_repository.dart';
import '../../../orders/domain/order_models.dart';
import '../../../orders/presentation/utils/customer_order_navigation.dart';
import '../../../orders/presentation/utils/customer_order_notification_utils.dart';

/// Inbox tab — surfaces order-status notifications derived from the customer's
/// active orders. Polls in the background so updates appear without a manual
/// refresh, mirroring the home screen's notifications cadence.
class CustomerInboxScreen extends StatefulWidget {
  const CustomerInboxScreen({super.key});

  @override
  State<CustomerInboxScreen> createState() => _CustomerInboxScreenState();
}

class _CustomerInboxScreenState extends State<CustomerInboxScreen> {
  static const Duration _pollInterval = Duration(seconds: 45);

  List<OrderSummary> _notifications = <OrderSummary>[];
  bool _loading = true;
  String? _error;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<OrderSummary> data = await _fetch();
      if (!mounted) return;
      setState(() {
        _notifications = data;
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

  /// Background refresh — updates the list silently without flipping the
  /// screen back into its loading/error state.
  Future<void> _refresh() async {
    try {
      final List<OrderSummary> data = await _fetch();
      if (!mounted) return;
      setState(() => _notifications = data);
    } catch (_) {
      // Keep the last good list on a transient poll failure.
    }
  }

  Future<List<OrderSummary>> _fetch() async {
    final String? token = context.read<AuthRepository>().currentSession?.accessToken;
    if (token == null) throw Exception('Not signed in');
    final List<OrderSummary> orders =
        await context.read<OrderRepository>().fetchMyOrders(accessToken: token);
    return orders.where(CustomerOrderNotificationUtils.isNotifiable).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CustomerCheckoutTokens.canvas,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Inbox',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: CustomerCheckoutTokens.ink,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: CustomerCheckoutTokens.primaryMaroon),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _error ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerCheckoutTokens.bodyGray,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: CustomerCheckoutTokens.primaryMaroon,
                  foregroundColor: CustomerCheckoutTokens.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: CustomerCheckoutTokens.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_notifications.isEmpty) {
      return RefreshIndicator(
        color: CustomerCheckoutTokens.primaryMaroon,
        onRefresh: _load,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 48),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: CustomerCheckoutTokens.dropoffTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 36,
                      color: CustomerCheckoutTokens.primaryMaroon,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: CustomerCheckoutTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Updates about your active orders will show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomerCheckoutTokens.bodyGray,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: CustomerCheckoutTokens.primaryMaroon,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final OrderSummary order = _notifications[index];
          return Material(
            color: CustomerCheckoutTokens.cardSurface,
            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
              onTap: () => CustomerOrderNavigation.openSummary(context, order),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CustomerCheckoutTokens.fieldFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        order.isAwaitingOnlinePayment
                            ? Icons.payments_outlined
                            : Icons.delivery_dining_outlined,
                        color: CustomerCheckoutTokens.primaryMaroon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            CustomerOrderNotificationUtils.headline(order),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: CustomerCheckoutTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CustomerOrderNotificationUtils.subtitle(order),
                            style: const TextStyle(
                              color: CustomerCheckoutTokens.bodyGray,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: CustomerCheckoutTokens.bodyGray,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
