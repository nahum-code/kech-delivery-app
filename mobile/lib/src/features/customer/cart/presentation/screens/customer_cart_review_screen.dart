import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../data/cart_repository.dart';
import '../../domain/cart_models.dart';
import '../../domain/checkout_draft.dart';
import '../widgets/customer_delivery_address_sheet.dart';
import '../widgets/customer_maroon_primary_button.dart';
import '../widgets/customer_quantity_selector.dart';
import 'customer_checkout_screen.dart';

/// Cart review — production "Your cart" screen before pay-with-Chapa checkout.
class CustomerCartReviewScreen extends StatefulWidget {
  const CustomerCartReviewScreen({super.key});

  @override
  State<CustomerCartReviewScreen> createState() => _CustomerCartReviewScreenState();
}

class _CustomerCartReviewScreenState extends State<CustomerCartReviewScreen> {
  CheckoutDraft? _draft;

  int get _itemCount =>
      context.read<CartRepository>().current?.lines.fold<int>(0, (int s, CartLine l) => s + l.quantity) ?? 0;

  double get _deliveryFee => CustomerCheckoutTokens.defaultDeliveryFee;

  Future<void> _editAddress() async {
    final CheckoutDraft? updated = await showCustomerDeliveryAddressSheet(context, initial: _draft);
    if (updated != null && mounted) setState(() => _draft = updated);
  }

  void _goCheckout() {
    if (_draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a delivery address to continue.')),
      );
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CustomerCheckoutScreen(draft: _draft!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartState? cart = context.watch<CartRepository>().current;
    final String currency =
        cart != null && cart.lines.isNotEmpty ? cart.lines.first.currency : 'ETB';

    return Scaffold(
      backgroundColor: CustomerCheckoutTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerCheckoutTokens.canvas,
        elevation: 0,
        foregroundColor: CustomerCheckoutTokens.primaryMaroon,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w800, color: CustomerCheckoutTokens.ink)),
        actions: <Widget>[
          Icon(Icons.shopping_bag_outlined, color: CustomerCheckoutTokens.primaryMaroon),
          if (_itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 4),
              child: Center(
                child: Text('$_itemCount', style: const TextStyle(fontWeight: FontWeight.w800, color: CustomerCheckoutTokens.primaryMaroon)),
              ),
            ),
        ],
      ),
      body: cart == null || cart.isEmpty
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
                      Row(
                        children: <Widget>[
                          Text('Your cart', style: CustomerCheckoutTokens.sectionTitle(context)),
                          const Spacer(),
                          Text(
                            '$_itemCount ITEMS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CustomerCheckoutTokens.mutedGray,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...cart.lines.map((CartLine line) => _CartLineCard(line: line)),
                      const SizedBox(height: 16),
                      _DeliveryCard(
                        draft: _draft,
                        onChange: _editAddress,
                      ),
                      const SizedBox(height: 16),
                      _PriceRow(label: 'Subtotal', value: '${cart.subtotal.toStringAsFixed(2)} $currency'),
                      const SizedBox(height: 8),
                      _PriceRow(label: 'Delivery fee', value: '${_deliveryFee.toStringAsFixed(2)} $currency'),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: CustomerMaroonPrimaryButton(label: 'CHECKOUT', onPressed: _goCheckout),
                ),
              ],
            ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final CartRepository repo = context.read<CartRepository>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: CustomerCheckoutTokens.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: line.imageUrl != null
                        ? Image.network(line.imageUrl!, fit: BoxFit.cover)
                        : ColoredBox(
                            color: CustomerCheckoutTokens.fieldFill,
                            child: Icon(Icons.fastfood_rounded, color: CustomerCheckoutTokens.mutedGray),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(line.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      if (line.subtitle.isNotEmpty)
                        Text(line.subtitle, style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '${line.unitPrice} ${line.currency}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: CustomerCheckoutTokens.primaryMaroon,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomerQuantitySelector(
                  quantity: line.quantity,
                  onDecrement: () => repo.updateLineQuantity(line.menuItemId, line.quantity - 1),
                  onIncrement: () => repo.updateLineQuantity(line.menuItemId, line.quantity + 1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LineInstructionsField(
              initial: line.specialInstructions,
              onChanged: (String v) => repo.updateLineInstructions(line.menuItemId, v),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.draft, required this.onChange});

  final CheckoutDraft? draft;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final bool hasAddress = draft != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomerCheckoutTokens.deliveryTeal,
        borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.location_on_rounded, color: CustomerCheckoutTokens.deliveryTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'DELIVER TO',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  hasAddress ? '${draft!.addressLabel} — ${draft!.address.addressLine}' : 'Add delivery address',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.25),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _LineInstructionsField extends StatefulWidget {
  const _LineInstructionsField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_LineInstructionsField> createState() => _LineInstructionsFieldState();
}

class _LineInstructionsFieldState extends State<_LineInstructionsField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Add special instructions...',
        hintStyle: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 13),
        filled: true,
        fillColor: CustomerCheckoutTokens.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label, style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ],
    );
  }
}
