import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../payments/data/payment_repository.dart';
import '../../data/order_repository.dart';
import '../../domain/order_models.dart';
import 'customer_order_tracking_screen.dart';

/// Payment pending — polls order and verifies with Chapa via backend.
class CustomerPaymentPendingScreen extends StatefulWidget {
  const CustomerPaymentPendingScreen({
    super.key,
    required this.orderId,
    this.initial,
    this.txRef,
  });

  final int orderId;
  final OrderDetail? initial;
  final String? txRef;

  @override
  State<CustomerPaymentPendingScreen> createState() => _CustomerPaymentPendingScreenState();
}

class _CustomerPaymentPendingScreenState extends State<CustomerPaymentPendingScreen> {
  OrderDetail? _order;
  bool _refreshing = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _order = widget.initial;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh(silent: true));
    _refresh(silent: false);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({required bool silent}) async {
    if (_refreshing) return;
    if (!silent) setState(() => _refreshing = true);
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');

      if (widget.txRef != null && widget.txRef!.isNotEmpty) {
        await context.read<PaymentRepository>().verifyPayment(
              accessToken: token,
              txRef: widget.txRef,
            );
      } else {
        await context.read<PaymentRepository>().verifyPayment(
              accessToken: token,
              orderId: widget.orderId,
            );
      }

      final OrderDetail order = await context.read<OrderRepository>().fetchOrderDetail(
            accessToken: token,
            orderId: widget.orderId,
          );
      if (!mounted) return;
      setState(() {
        _order = order;
        _error = null;
      });
      if (order.isPaymentPaid) _goToTracking(order);
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        try {
          final String? token = context.read<AuthRepository>().currentSession?.accessToken;
          if (token != null) {
            final OrderDetail order = await context.read<OrderRepository>().fetchOrderDetail(
                  accessToken: token,
                  orderId: widget.orderId,
                );
            if (!mounted) return;
            setState(() => _order = order);
            if (order.isPaymentPaid) {
              _goToTracking(order);
              return;
            }
          }
        } catch (_) {}
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted && !silent) setState(() => _refreshing = false);
    }
  }

  void _goToTracking(OrderDetail order) {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => CustomerOrderTrackingScreen(orderId: order.id, initial: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String reference = _order?.reference ?? '…';

    return Scaffold(
      backgroundColor: CustomerCheckoutTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerCheckoutTokens.canvas,
        elevation: 0,
        foregroundColor: CustomerCheckoutTokens.primaryMaroon,
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.w800, color: CustomerCheckoutTokens.primaryMaroon)),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: CustomerCheckoutTokens.primaryMaroon.withValues(alpha: 0.1),
              child: const Icon(Icons.help_outline_rounded, size: 18, color: CustomerCheckoutTokens.primaryMaroon),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: <Widget>[
          const SizedBox(height: 12),
          const Center(child: _PaymentProgressRing()),
          const SizedBox(height: 24),
          const Text(
            'Payment pending',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: CustomerCheckoutTokens.primaryMaroon,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: CustomerCheckoutTokens.primaryMaroon, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Payment pending',
                style: TextStyle(color: CustomerCheckoutTokens.primaryMaroon.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: CustomerCheckoutTokens.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: CustomerCheckoutTokens.primaryMaroon, width: 3)),
            ),
            child: Text(
              'We are waiting for confirmation from the bank. This usually takes a few seconds. Please do not close the app or refresh.',
              style: TextStyle(color: CustomerCheckoutTokens.ink.withValues(alpha: 0.85), height: 1.45, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_refreshing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: CustomerCheckoutTokens.mutedGray),
                )
              else
                Icon(Icons.refresh_rounded, size: 16, color: CustomerCheckoutTokens.mutedGray),
              const SizedBox(width: 6),
              Text(
                'Refreshing status…',
                style: TextStyle(
                  color: CustomerCheckoutTokens.mutedGray,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 8),
            TextButton(onPressed: () => _refresh(silent: false), child: const Text('Retry verification')),
          ],
          const SizedBox(height: 28),
          Material(
            color: CustomerCheckoutTokens.cardSurface,
            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            elevation: 1,
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CustomerCheckoutTokens.fieldFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: CustomerCheckoutTokens.primaryMaroon),
              ),
              title: Text('Order reference', style: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 12)),
              subtitle: Text('#$reference', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              trailing: Icon(Icons.chevron_right_rounded, color: CustomerCheckoutTokens.mutedGray),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentProgressRing extends StatelessWidget {
  const _PaymentProgressRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 4,
              backgroundColor: const Color(0xFFE8E8E8),
              color: CustomerCheckoutTokens.primaryMaroon,
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.hourglass_top_rounded, size: 36, color: CustomerCheckoutTokens.primaryMaroon),
          ),
        ],
      ),
    );
  }
}
