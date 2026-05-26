import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/driver_home_tokens.dart';
import '../../../../../shared/theme/driver_task_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';

/// Returned by [DriverBroadcastOfferDetailScreen] so the parent knows which
/// action the driver picked.
enum BroadcastOfferAction { accept, skip }

class DriverBroadcastOfferDetailScreen extends StatefulWidget {
  const DriverBroadcastOfferDetailScreen({
    super.key,
    required this.orderId,
    required this.reference,
  });

  final int orderId;
  final String reference;

  @override
  State<DriverBroadcastOfferDetailScreen> createState() => _DriverBroadcastOfferDetailScreenState();
}

class _DriverBroadcastOfferDetailScreenState extends State<DriverBroadcastOfferDetailScreen> {
  DriverOrderDetail? _order;
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
      final DriverOrderDetail detail = await context
          .read<DriverOrderRepository>()
          .fetchAvailableDetail(accessToken: token, orderId: widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverHomeTokens.screenBackground,
      appBar: AppBar(
        backgroundColor: DriverHomeTokens.screenBackground,
        elevation: 0,
        foregroundColor: DriverTaskTokens.primary,
        title: Text(
          'Order #${widget.reference}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: DriverTaskTokens.primary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: DriverTaskTokens.primary))
          : _error != null
              ? _buildError(_error!)
              : _buildContent(_order!),
      bottomNavigationBar: _order == null || _error != null ? null : _buildActions(),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: DriverTaskTokens.primary, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(BroadcastOfferAction.skip),
              style: FilledButton.styleFrom(backgroundColor: DriverTaskTokens.primary),
              child: const Text('Back to alerts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DriverOrderDetail order) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: <Widget>[
        _section(
          icon: Icons.storefront_outlined,
          label: 'PICKUP',
          title: order.restaurantName.isEmpty ? 'Restaurant' : order.restaurantName,
          subtitle: order.restaurantAddress,
        ),
        const SizedBox(height: 12),
        _section(
          icon: Icons.location_on_outlined,
          label: 'DROPOFF',
          title: order.deliveryAddress.addressLine.isEmpty
              ? '—'
              : order.deliveryAddress.addressLine,
          subtitle: order.deliveryAddress.landmark,
        ),
        if (order.customerNote.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE6CFA1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.sticky_note_2_outlined, color: Color(0xFFB07D2A), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'SPECIAL INSTRUCTIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFFB07D2A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.customerNote,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5C4A4A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'ITEMS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: DriverTaskTokens.primary,
          ),
        ),
        const SizedBox(height: 10),
        if (order.items.isEmpty)
          const Text('No item details available.', style: TextStyle(color: Color(0xFF8B6B6B))),
        for (final OrderLineItem item in order.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: <Widget>[
                Text(
                  '${item.quantity}×',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: DriverTaskTokens.primary),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14))),
                Text(
                  '${item.totalPrice} ETB',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5C4A4A)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6D8DA)),
          ),
          child: Column(
            children: <Widget>[
              _moneyRow('Subtotal', '${order.subtotal} ETB'),
              const SizedBox(height: 6),
              _moneyRow('Delivery fee', '${order.deliveryFee} ETB'),
              const Divider(height: 18),
              _moneyRow('You earn', '${order.deliveryFee} ETB', emphasis: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moneyRow(String label, String value, {bool emphasis = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: emphasis ? DriverTaskTokens.primary : const Color(0xFF8B6B6B),
            fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
            fontSize: emphasis ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasis ? DriverTaskTokens.primary : const Color(0xFF5C4A4A),
            fontWeight: FontWeight.w800,
            fontSize: emphasis ? 15 : 13,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required IconData icon,
    required String label,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6D8DA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: DriverTaskTokens.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: DriverTaskTokens.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                if (subtitle.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF8B6B6B))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(BroadcastOfferAction.skip),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DriverTaskTokens.primary,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFE6D8DA)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(BroadcastOfferAction.accept),
                style: FilledButton.styleFrom(
                  backgroundColor: DriverTaskTokens.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
