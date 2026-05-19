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
