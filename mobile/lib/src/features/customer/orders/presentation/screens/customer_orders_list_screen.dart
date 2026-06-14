import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../data/order_repository.dart';
import '../../domain/order_models.dart';
import '../utils/customer_order_navigation.dart';

class CustomerOrdersListScreen extends StatefulWidget {
  const CustomerOrdersListScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<CustomerOrdersListScreen> createState() => CustomerOrdersListScreenState();
}

class CustomerOrdersListScreenState extends State<CustomerOrdersListScreen> {
  List<OrderSummary> _orders = <OrderSummary>[];
  bool _loading = true;
  String? _error;

  /// Currently selected status filter; null means "All".
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');
      final List<OrderSummary> data =
          await context.read<OrderRepository>().fetchMyOrders(accessToken: token);
      if (!mounted) return;
      setState(() {
        _orders = data;
        _loading = false;
        // Drop a stale filter if no loaded order has that status anymore.
        if (_statusFilter != null &&
            !data.any((OrderSummary o) => o.status == _statusFilter)) {
          _statusFilter = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').split(' ').map((String w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }

  /// Distinct statuses present in the loaded orders, preserving first-seen order.
  List<String> get _availableStatuses {
    final List<String> seen = <String>[];
    for (final OrderSummary o in _orders) {
      if (o.status.isNotEmpty && !seen.contains(o.status)) seen.add(o.status);
    }
    return seen;
  }

  List<OrderSummary> get _visibleOrders {
    if (_statusFilter == null) return _orders;
    return _orders
        .where((OrderSummary o) => o.status == _statusFilter)
        .toList(growable: false);
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Your orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: CustomerCheckoutTokens.ink,
                ),
              ),
            ),
            _buildStatusFilter(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    // Only worth showing when there are multiple statuses to filter between.
    final List<String> statuses = _availableStatuses;
    if (_loading || _error != null || statuses.length < 2) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        itemCount: statuses.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _StatusChip(
              label: 'All',
              selected: _statusFilter == null,
              onTap: () => setState(() => _statusFilter = null),
            );
          }
          final String status = statuses[index - 1];
          return _StatusChip(
            label: _statusLabel(status),
            selected: _statusFilter == status,
            onTap: () => setState(() => _statusFilter = status),
          );
        },
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
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: CustomerCheckoutTokens.dropoffTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 36,
                  color: CustomerCheckoutTokens.primaryMaroon,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No orders yet',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: CustomerCheckoutTokens.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'When you place an order, it will show up here.',
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
      );
    }

    final List<OrderSummary> visible = _visibleOrders;
    if (visible.isEmpty) {
      return RefreshIndicator(
        color: CustomerCheckoutTokens.primaryMaroon,
        onRefresh: _load,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
              child: Column(
                children: <Widget>[
                  Text(
                    'No ${_statusFilter != null ? '${_statusLabel(_statusFilter!).toLowerCase()} ' : ''}orders',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: CustomerCheckoutTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try a different status filter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomerCheckoutTokens.bodyGray,
                      fontSize: 14,
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
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final OrderSummary o = visible[index];
          return Material(
            color: CustomerCheckoutTokens.cardSurface,
            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
              onTap: () => CustomerOrderNavigation.openSummary(context, o),
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
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: CustomerCheckoutTokens.primaryMaroon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            o.reference,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: CustomerCheckoutTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            o.restaurantName,
                            style: const TextStyle(
                              color: CustomerCheckoutTokens.bodyGray,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusLabel(o.status),
                            style: const TextStyle(
                              color: CustomerCheckoutTokens.primaryMaroon,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${o.totalAmount} ETB',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: CustomerCheckoutTokens.ink,
                      ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CustomerCheckoutTokens.primaryMaroon : CustomerCheckoutTokens.cardSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? CustomerCheckoutTokens.primaryMaroon : const Color(0xFFE5E5E5),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? CustomerCheckoutTokens.onPrimary : CustomerCheckoutTokens.bodyGray,
            ),
          ),
        ),
      ),
    );
  }
}
