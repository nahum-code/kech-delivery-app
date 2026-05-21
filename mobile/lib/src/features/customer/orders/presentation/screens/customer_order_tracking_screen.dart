import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../data/order_repository.dart';
import '../../domain/order_models.dart';
import '../widgets/customer_order_journey_stepper.dart';

/// Live order tracking — journey timeline + map placeholder.
class CustomerOrderTrackingScreen extends StatefulWidget {
  const CustomerOrderTrackingScreen({
    super.key,
    required this.orderId,
    this.initial,
  });

  final int orderId;
  final OrderDetail? initial;

  @override
  State<CustomerOrderTrackingScreen> createState() => _CustomerOrderTrackingScreenState();
}

class _CustomerOrderTrackingScreenState extends State<CustomerOrderTrackingScreen> {
  OrderDetail? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _order = widget.initial;
      _loading = false;
    }
    _load();
  }

  Future<void> _load() async {
    if (widget.initial == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');
      final OrderDetail order = await context.read<OrderRepository>().fetchOrderDetail(
            accessToken: token,
            orderId: widget.orderId,
          );
      if (!mounted) return;
      setState(() {
        _order = order;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerCheckoutTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerCheckoutTokens.canvas,
        elevation: 0,
        foregroundColor: CustomerCheckoutTokens.primaryMaroon,
        title: Text(
          _order != null ? 'Order #${_order!.reference}' : 'Order tracking',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: CustomerCheckoutTokens.ink),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'KECH DELIVERY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: CustomerCheckoutTokens.primaryMaroon,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CustomerCheckoutTokens.primaryMaroon))
          : _error != null
              ? Center(child: TextButton(onPressed: _load, child: Text('Retry\n$_error')))
              : _buildBody(_order!),
    );
  }

  Widget _buildBody(OrderDetail order) {
    final bool searchingDriver = order.isPaymentPaid &&
        !<String>['assigned', 'picked_up', 'delivering', 'delivered'].contains(order.status);

    return RefreshIndicator(
      color: CustomerCheckoutTokens.primaryMaroon,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Track journey', style: CustomerCheckoutTokens.sectionTitle(context)),
                const SizedBox(height: 16),
                CustomerOrderJourneyStepper(order: order),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(color: CustomerCheckoutTokens.mapPlaceholder),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          searchingDriver ? Icons.two_wheeler_rounded : Icons.delivery_dining_rounded,
                          size: 32,
                          color: CustomerCheckoutTokens.primaryMaroon,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          searchingDriver ? 'Searching driver…' : _mapCaption(order.status),
                          style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _OrderItemsCard(order: order),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomerCheckoutTokens.dropoffTint,
              borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'DROPOFF POINT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: CustomerCheckoutTokens.primaryMaroon,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.deliveryAddress.addressLine,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.35),
                ),
                if (order.deliveryAddress.landmark.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(order.deliveryAddress.landmark, style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _mapCaption(String status) {
    switch (status) {
      case 'assigned':
        return 'Driver assigned';
      case 'picked_up':
        return 'Order picked up';
      case 'delivering':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Preparing your order';
    }
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'YOUR ORDER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: CustomerCheckoutTokens.primaryMaroon,
                ),
              ),
              Text(
                order.restaurantName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CustomerCheckoutTokens.bodyGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.items.isEmpty)
            Text(
              'No items recorded for this order.',
              style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13),
            )
          else
            ...order.items.map((OrderLineItem item) => _OrderItemRow(item: item)),
          const SizedBox(height: 4),
          const Divider(height: 24),
          _SummaryRow(label: 'Subtotal', value: '${order.subtotal} ETB'),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Delivery fee', value: '${order.deliveryFee} ETB'),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Total', value: '${order.totalAmount} ETB', emphasis: true),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _itemPlaceholder(),
                    )
                  : _itemPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice} ETB',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: CustomerCheckoutTokens.primaryMaroon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemPlaceholder() {
    return ColoredBox(
      color: const Color(0xFFF0EBE8),
      child: Icon(Icons.fastfood, color: Colors.grey.shade500, size: 20),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = TextStyle(
      fontSize: emphasis ? 15 : 13,
      fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
      color: emphasis ? CustomerCheckoutTokens.ink : CustomerCheckoutTokens.bodyGray,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: base),
        Text(
          value,
          style: emphasis ? base.copyWith(color: CustomerCheckoutTokens.primaryMaroon) : base,
        ),
      ],
    );
  }
}
