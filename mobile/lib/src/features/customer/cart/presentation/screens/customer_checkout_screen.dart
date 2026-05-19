import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../orders/data/order_repository.dart';
import '../../../orders/domain/order_models.dart';
import '../../../orders/presentation/screens/customer_order_detail_screen.dart';
import '../../data/cart_repository.dart';
import '../../domain/cart_models.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _note = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _landmark.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final CartState? cart = context.read<CartRepository>().current;
    if (cart == null || cart.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');

      final OrderDetail placed = await context.read<OrderRepository>().placeOrder(
            accessToken: token,
            cart: cart,
            address: DeliveryAddress(
              receiverName: _name.text.trim(),
              phone: _phone.text.trim(),
              addressLine: _address.text.trim(),
              landmark: _landmark.text.trim(),
            ),
            customerNote: _note.text.trim(),
          );
      if (!mounted) return;
      await context.read<CartRepository>().clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => CustomerOrderDetailScreen(orderId: placed.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartState? cart = context.watch<CartRepository>().current;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart == null
          ? const Center(child: Text('Cart is empty'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(cart.restaurantName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Subtotal: ${cart.subtotal.toStringAsFixed(2)} MAD'),
                  const SizedBox(height: 20),
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Receiver name *')),
                  const SizedBox(height: 12),
                  TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone *'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address *'), maxLines: 2),
                  const SizedBox(height: 12),
                  TextField(controller: _landmark, decoration: const InputDecoration(labelText: 'Landmark (optional)')),
                  const SizedBox(height: 12),
                  TextField(controller: _note, decoration: const InputDecoration(labelText: 'Note for restaurant')),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _placeOrder,
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Place order'),
                  ),
                ],
              ),
            ),
    );
  }
}
