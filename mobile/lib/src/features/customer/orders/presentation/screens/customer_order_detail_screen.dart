import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../data/order_repository.dart';
import '../../domain/order_models.dart';

/// Order history detail — aligned with production design spec.
class CustomerOrderDetailScreen extends StatefulWidget {
  const CustomerOrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  static const Color _maroon = Color(0xFF800020);

  @override
  State<CustomerOrderDetailScreen> createState() => _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState extends State<CustomerOrderDetailScreen> {
  OrderDetail? _order;
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

  String _formatDate(String iso) {
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      return '${dt.day} ${_month(dt.month)} ${dt.year}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _month(int m) {
    const List<String> names = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m - 1];
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').split(' ').map((String w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: CustomerOrderDetailScreen._maroon,
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.w700, color: CustomerOrderDetailScreen._maroon),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: CustomerOrderDetailScreen._maroon))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _buildContent(_order!),
    );
  }

  Widget _buildContent(OrderDetail order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'ORDER #${order.reference}',
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 1.2,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE8),
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: CustomerOrderDetailScreen._maroon, width: 4)),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.check_circle, color: CustomerOrderDetailScreen._maroon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _statusLabel(order.status),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: CustomerOrderDetailScreen._maroon,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.placedAt),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Items snapshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...order.items.map((OrderLineItem item) => _ItemCard(item: item)),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(child: _LocationCard(
                label: 'MERCHANT',
                title: order.restaurantName,
                icon: Icons.storefront_outlined,
              )),
              const SizedBox(width: 12),
              Expanded(
                child: _LocationCard(
                  label: 'DROPOFF',
                  title: order.deliveryAddress.addressLine,
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: CustomerOrderDetailScreen._maroon,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('REORDER NOW', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download receipt'),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : ColoredBox(color: Colors.grey.shade200, child: Icon(Icons.fastfood, color: Colors.grey.shade500)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('Qty: ${item.quantity}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Text(
              '${item.totalPrice} MAD',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: CustomerOrderDetailScreen._maroon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.label, required this.title, required this.icon});

  final String label;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: CustomerOrderDetailScreen._maroon),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: CustomerOrderDetailScreen._maroon)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
