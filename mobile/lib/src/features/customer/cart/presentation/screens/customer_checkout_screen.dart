import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../../shared/widgets/map/customer_address_map_picker.dart';
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

enum _PaymentMethod { chapa, pod }

/// Checkout screen with Chapa and Pay-on-Delivery options.
class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key, required this.draft, this.restaurant});

  final CheckoutDraft draft;
  final RestaurantOnMap? restaurant;

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  late CheckoutDraft _draft;
  final TextEditingController _driverNote = TextEditingController();
  bool _submitting = false;
  // Chapa online payment is temporarily disabled (coming soon), so default to
  // pay-on-delivery.
  _PaymentMethod _paymentMethod = _PaymentMethod.pod;

  DeliveryFeeQuote? _quote;
  bool _quoteLoading = false;
  String? _quoteError;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _driverNote.text = widget.draft.driverNote;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final CartState? cart = context.read<CartRepository>().current;
      if (cart == null || cart.isEmpty) {
        Navigator.of(context).maybePop();
        return;
      }
      _refreshQuote();
    });
  }

  @override
  void dispose() {
    _driverNote.dispose();
    super.dispose();
  }

  double get _deliveryFee {
    if (_quote != null) {
      return double.tryParse(_quote!.deliveryFee) ?? CustomerCheckoutTokens.defaultDeliveryFee;
    }
    return CustomerCheckoutTokens.defaultDeliveryFee;
  }

  Future<void> _refreshQuote() async {
    final CartState? cart = context.read<CartRepository>().current;
    if (cart == null) return;
    final double? lat = _draft.address.latitude;
    final double? lng = _draft.address.longitude;
    if (lat == null || lng == null) {
      setState(() {
        _quote = null;
        _quoteError = null;
      });
      return;
    }
    final String? token = context.read<AuthRepository>().currentSession?.accessToken;
    if (token == null) return;
    setState(() {
      _quoteLoading = true;
      _quoteError = null;
    });
    try {
      final DeliveryFeeQuote q = await context.read<OrderRepository>().quoteDeliveryFee(
            accessToken: token,
            restaurantId: cart.restaurantId,
            latitude: lat,
            longitude: lng,
          );
      if (!mounted) return;
      setState(() => _quote = q);
    } catch (e) {
      if (!mounted) return;
      setState(() => _quoteError = e.toString());
    } finally {
      if (mounted) setState(() => _quoteLoading = false);
    }
  }

  Future<void> _changeAddress() async {
    final CheckoutDraft? updated = await showCustomerDeliveryAddressSheet(
      context,
      initial: _draft,
      restaurant: widget.restaurant,
    );
    if (updated != null && mounted) {
      setState(() => _draft = updated.copyWith(driverNote: _driverNote.text.trim()));
      _refreshQuote();
    }
  }

  String _buildNote(CartState cart) {
    return <String>[
      if (_driverNote.text.trim().isNotEmpty) _driverNote.text.trim(),
      ...cart.lines
          .where((CartLine l) => l.specialInstructions.isNotEmpty)
          .map((CartLine l) => '${l.name}: ${l.specialInstructions}'),
    ].join('\n');
  }

  Future<void> _submit() async {
    if (_paymentMethod == _PaymentMethod.pod) {
      await _payOnDelivery();
    } else {
      await _payWithChapa();
    }
  }

  Future<void> _payWithChapa() async {
    final CartState? cart = context.read<CartRepository>().current;
    if (cart == null || cart.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');

      final OrderDetail placed = await context.read<OrderRepository>().placeOrder(
            accessToken: token,
            cart: cart,
            address: _draft.address,
            customerNote: _buildNote(cart),
            paymentMethod: 'chapa',
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

  Future<void> _payOnDelivery() async {
    final CartState? cart = context.read<CartRepository>().current;
    if (cart == null || cart.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final String? token = context.read<AuthRepository>().currentSession?.accessToken;
      if (token == null) throw Exception('Not signed in');

      final OrderDetail placed = await context.read<OrderRepository>().placeOrder(
            accessToken: token,
            cart: cart,
            address: _draft.address,
            customerNote: _buildNote(cart),
            paymentMethod: 'pod',
          );
      if (!mounted) return;
      await context.read<CartRepository>().clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${placed.reference} placed. Pay the driver on delivery.')),
      );
      Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
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
      body: cart == null || cart.isEmpty
          ? const Center(child: CircularProgressIndicator(color: CustomerCheckoutTokens.primaryMaroon))
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      CustomerCheckoutTokens.screenPadding,
                      8,
                      CustomerCheckoutTokens.screenPadding,
                      24,
                    ),
                    children: <Widget>[
                      if (cart.lines.isNotEmpty) ...<Widget>[
                        Text('Your order', style: CustomerCheckoutTokens.sectionTitle(context)),
                        const SizedBox(height: 10),
                        ...cart.lines.map(
                          (CartLine line) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    line.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: CustomerCheckoutTokens.ink,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      '${line.quantity} × ${line.unitPrice} ${line.currency}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: CustomerCheckoutTokens.ink,
                                      ),
                                    ),
                                    if (line.boxPrice > 0)
                                      Text(
                                        '+ ${line.takeawayBoxPrice} ${line.currency} box',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: CustomerCheckoutTokens.mutedGray,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text('Delivery destination', style: CustomerCheckoutTokens.sectionTitle(context)),
                      const SizedBox(height: 10),
                      _AddressCard(draft: _draft, onChange: _changeAddress),
                      const SizedBox(height: 24),
                      Text('Instructions for driver', style: CustomerCheckoutTokens.sectionTitle(context)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _driverNote,
                        maxLines: 3,
                        style: const TextStyle(
                          color: CustomerCheckoutTokens.ink,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        cursorColor: CustomerCheckoutTokens.primaryMaroon,
                        decoration: InputDecoration(
                          hintText: 'Add a note for the driver... (e.g. gate code, leave at door)',
                          hintStyle: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 13),
                          filled: true,
                          fillColor: CustomerCheckoutTokens.fieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                            borderSide: const BorderSide(color: CustomerCheckoutTokens.primaryMaroon, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Payment method', style: CustomerCheckoutTokens.sectionTitle(context)),
                      const SizedBox(height: 10),
                      _PaymentMethodTile(
                        title: 'Chapa',
                        subtitle: 'Fast & secure online payment',
                        selected: _paymentMethod == _PaymentMethod.chapa,
                        iconBg: CustomerCheckoutTokens.chapaBlue,
                        iconText: 'C',
                        comingSoon: true,
                      ),
                      const SizedBox(height: 10),
                      _PaymentMethodTile(
                        title: 'Pay on delivery',
                        subtitle: 'Pay cash to the driver when your order arrives',
                        selected: _paymentMethod == _PaymentMethod.pod,
                        iconBg: CustomerCheckoutTokens.primaryMaroon,
                        iconChild: const Icon(Icons.payments_outlined, color: Colors.white, size: 24),
                        onTap: () => setState(() => _paymentMethod = _PaymentMethod.pod),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        decoration: BoxDecoration(
                          color: CustomerCheckoutTokens.fieldFill,
                          borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                        ),
                        child: DefaultTextStyle(
                          style: const TextStyle(color: CustomerCheckoutTokens.ink),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Order summary', style: CustomerCheckoutTokens.sectionTitle(context)),
                              const SizedBox(height: 14),
                              _summaryRow('Subtotal', '${subtotal.toStringAsFixed(2)} $currency'),
                              const SizedBox(height: 10),
                              _summaryRow(
                                'Delivery fee',
                                _quoteLoading
                                    ? 'Calculating…'
                                    : '${_deliveryFee.toStringAsFixed(2)} $currency',
                              ),
                              if (_quote != null) ...<Widget>[
                                const SizedBox(height: 4),
                                Text(
                                  _quote!.distanceKm != null
                                      ? 'Distance ${double.tryParse(_quote!.distanceKm!)?.toStringAsFixed(2) ?? _quote!.distanceKm} km · driver ${_quote!.driverPayout} + platform ${_quote!.platformFee}'
                                      : 'Default fare (no map pin) · driver ${_quote!.driverPayout} + platform ${_quote!.platformFee}',
                                  style: const TextStyle(
                                    color: CustomerCheckoutTokens.mutedGray,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              if (_quoteError != null) ...<Widget>[
                                const SizedBox(height: 4),
                                Text(
                                  _quoteError!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                                ),
                              ],
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 14),
                              _summaryRow('Total', '${total.toStringAsFixed(2)} $currency', bold: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: CustomerMaroonPrimaryButton(
                    label: _paymentMethod == _PaymentMethod.pod
                        ? 'PLACE ORDER (PAY ON DELIVERY)'
                        : 'PAY WITH CHAPA',
                    loading: _submitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 15 : 14,
            color: CustomerCheckoutTokens.bodyGray,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: bold ? 16 : 15,
            color: CustomerCheckoutTokens.ink,
          ),
        ),
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
                Text(
                  draft.addressLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: CustomerCheckoutTokens.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  draft.address.addressLine,
                  style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13, height: 1.4),
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.iconBg,
    this.onTap,
    this.iconText,
    this.iconChild,
    this.comingSoon = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Color iconBg;
  final String? iconText;
  final Widget? iconChild;
  final VoidCallback? onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: comingSoon ? 0.55 : 1,
      child: InkWell(
        onTap: comingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CustomerCheckoutTokens.cardSurface,
            borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
            border: Border.all(
              color: selected
                  ? CustomerCheckoutTokens.primaryMaroon
                  : const Color(0xFFE5E5E5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: iconChild ??
                    Text(
                      iconText ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: CustomerCheckoutTokens.ink,
                            ),
                          ),
                        ),
                        if (comingSoon) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: CustomerCheckoutTokens.fieldFill,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Coming soon',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: CustomerCheckoutTokens.bodyGray,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: CustomerCheckoutTokens.bodyGray, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!comingSoon)
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: selected ? CustomerCheckoutTokens.primaryMaroon : CustomerCheckoutTokens.mutedGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
