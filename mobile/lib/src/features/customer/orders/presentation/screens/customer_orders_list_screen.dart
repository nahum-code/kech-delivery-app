import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../data/order_repository.dart';
import '../../domain/order_models.dart';
import 'customer_order_detail_screen.dart';

class CustomerOrdersListScreen extends StatefulWidget {
  const CustomerOrdersListScreen({super.key});

  @override
  State<CustomerOrdersListScreen> createState() => _CustomerOrdersListScreenState();
}

class _CustomerOrdersListScreenState extends State<CustomerOrdersListScreen> {
  List<OrderSummary> _orders = <OrderSummary>[];
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
      final List<OrderSummary> data =
          await context.read<OrderRepository>().fetchMyOrders(accessToken: token);
      if (!mounted) return;
      setState(() {
        _orders = data;
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
      appBar: AppBar(title: const Text('Your orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: TextButton(onPressed: _load, child: Text('Retry\n$_error')))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders yet'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final OrderSummary o = _orders[index];
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text(o.reference, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${o.restaurantName} · ${o.status}'),
                            trailing: Text('${o.totalAmount} MAD'),
                            onTap: () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => CustomerOrderDetailScreen(orderId: o.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
