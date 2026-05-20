import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../orders/data/order_repository.dart';
import '../../../orders/domain/order_models.dart';
import '../../../payments/data/payment_repository.dart';
import '../../../payments/presentation/screens/customer_chapa_checkout_screen.dart';
import '../../data/cart_repository.dart';
import '../../domain/cart_models.dart';
import '../../domain/checkout_draft.dart';
import '../widgets/customer_delivery_address_sheet.dart';
import '../widgets/customer_maroon_primary_button.dart';

/// Pay-with-Chapa checkout — creates order then opens payment pending.
class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key, required this.draft});

  final CheckoutDraft draft;

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  late CheckoutDraft _draft;
  final TextEditingController _driverNote = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _driverNote.text = widget.draft.driverNote;
  }

  @override
  void dispose() {
    _driverNote.dispose();
    super.dispose();
  }

  double get _deliveryFee => CustomerCheckoutTokens.defaultDeliveryFee;

  Future<void> _changeAddress() async {
    final CheckoutDraft? updated = await showCustomerDeliveryAddressSheet(context, initial: _draft);
    if (updated != null && mounted) {
      setState(() => _draft = updated.copyWith(driverNote: _driverNote.text.trim()));
    }
  }

  Future<void> _payWithChapa() async {
    final CartState? cart = context.read<CartRepository>().current;
    if (cart == null || cart.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');

      final String note = <String>[
        if (_driverNote.text.trim().isNotEmpty) _driverNote.text.trim(),
        ...cart.lines
            .where((CartLine l) => l.specialInstructions.isNotEmpty)
            .map((CartLine l) => '${l.name}: ${l.specialInstructions}'),
      ].join('\n');

      final OrderDetail placed = await context.read<OrderRepository>().placeOrder(
            accessToken: token,
            cart: cart,
            address: _draft.address,
            customerNote: note,
          );
      final paymentInit = await context.read<PaymentRepository>().initPayment(
            accessToken: token,
            orderId: placed.id,
          );
      if (paymentInit.checkoutUrl.trim().isEmpty) {
        throw Exception('Payment started but Chapa checkout link is missing.');
      }
      if (!mounted) return;
      await context.read<CartRepository>().clear();
      if (!mounted) return;
      await openChapaCheckout(
        context,
        orderId: placed.id,
        checkoutUrl: paymentInit.checkoutUrl,
        txRef: paymentInit.txRef,
        order: placed,
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
    final String currency = cart != null && cart.lines.isNotEmpty ? cart.lines.first.currency : 'ETB';
    final double subtotal = cart?.subtotal ?? 0;
    final double total = subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: CustomerCheckoutTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerCheckoutTokens.canvas,
        elevation: 0,
        foregroundColor: CustomerCheckoutTokens.primaryMaroon,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w800, color: CustomerCheckoutTokens.ink)),
        actions: const <Widget>[
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.shopping_bag_outlined)),
        ],
      ),
      body: cart == null
          ? const Center(child: Text('Cart is empty'))
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      CustomerCheckoutTokens.screenPadding,
                      0,
                      CustomerCheckoutTokens.screenPadding,
                      16,
                    ),
                    children: <Widget>[
                      Text('Delivery destination', style: CustomerCheckoutTokens.sectionTitle(context)),
                      const SizedBox(height: 10),
                      _AddressCard(draft: _draft, onChange: _changeAddress),
                      const SizedBox(height: 22),
                      Text('Instructions for driver', style: CustomerCheckoutTokens.sectionTitle(context)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _driverNote,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add a note for the driver... (e.g. gate code, leave at door)',
                          hintStyle: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 13),
                          filled: true,
                          fillColor: CustomerCheckoutTokens.fieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text('Payment method', style: CustomerCheckoutTokens.sectionTitle(context)),
                      const SizedBox(height: 10),
                      const _ChapaTile(),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CustomerCheckoutTokens.fieldFill,
                          borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Order summary', style: CustomerCheckoutTokens.sectionTitle(context)),
                            const SizedBox(height: 12),
                            _summaryRow('Subtotal', '${subtotal.toStringAsFixed(2)} $currency'),
                            const SizedBox(height: 8),
                            _summaryRow('Delivery fee', '${_deliveryFee.toStringAsFixed(2)} $currency'),
                            const Divider(height: 24),
                            _summaryRow('Total', '${total.toStringAsFixed(2)} $currency', bold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: CustomerMaroonPrimaryButton(
                    label: 'PAY WITH CHAPA',
                    loading: _submitting,
                    onPressed: _payWithChapa,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      children: <Widget>[
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w700)),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.draft, required this.onChange});

  final CheckoutDraft draft;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomerCheckoutTokens.cardSurface,
        borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CustomerCheckoutTokens.fieldFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded, color: CustomerCheckoutTokens.primaryMaroon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(draft.addressLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  draft.address.addressLine,
                  style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13, height: 1.35),
                ),
                if (draft.address.landmark.isNotEmpty)
                  Text(draft.address.landmark, style: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Change', style: TextStyle(color: CustomerCheckoutTokens.primaryMaroon, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ChapaTile extends StatelessWidget {
  const _ChapaTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomerCheckoutTokens.cardSurface,
        borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CustomerCheckoutTokens.chapaBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text('Chapa', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: CustomerCheckoutTokens.primaryMaroon.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PRIMARY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CustomerCheckoutTokens.primaryMaroon,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Fast & secure local payment', style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: CustomerCheckoutTokens.primaryMaroon),
        ],
      ),
    );
  }
}
