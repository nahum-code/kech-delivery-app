import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../cart/data/cart_repository.dart';
import '../../../cart/domain/cart_models.dart';
import '../../../cart/presentation/widgets/customer_maroon_primary_button.dart';
import '../../../cart/presentation/widgets/customer_quantity_selector.dart';
import '../../domain/restaurant_models.dart';

/// Item detail — quantity + special instructions before add to cart.
class CustomerMenuItemDetailScreen extends StatefulWidget {
  const CustomerMenuItemDetailScreen({
    super.key,
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
  });

  final PublicMenuItem item;
  final int restaurantId;
  final String restaurantName;

  @override
  State<CustomerMenuItemDetailScreen> createState() => _CustomerMenuItemDetailScreenState();
}

class _CustomerMenuItemDetailScreenState extends State<CustomerMenuItemDetailScreen> {
  static const Color _canvas = Color(0xFFFCF9F7);
  static const double _horizontalPadding = 20;

  int _quantity = 1;
  final TextEditingController _instructions = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      await context.read<CartRepository>().addItem(
            restaurantId: widget.restaurantId,
            restaurantName: widget.restaurantName,
            line: CartLine(
              menuItemId: widget.item.id,
              name: widget.item.name,
              unitPrice: widget.item.price,
              quantity: _quantity,
              imageUrl: widget.item.imageUrl,
              currency: widget.item.currency,
              subtitle: widget.item.description.length > 48
                  ? '${widget.item.description.substring(0, 48)}…'
                  : widget.item.description,
              specialInstructions: _instructions.text.trim(),
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  String _formatPrice(PublicMenuItem item) {
    final String amount = item.price.trim();
    if (amount.isEmpty) {
      return item.currency;
    }
    if (item.currency == 'USD' || item.currency == r'$') {
      return '\$$amount';
    }
    if (item.currency == 'MAD') {
      return '$amount MAD';
    }
    return '$amount ${item.currency}';
  }

  @override
  Widget build(BuildContext context) {
    final PublicMenuItem item = widget.item;

    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(_horizontalPadding, 4, _horizontalPadding, 16),
                children: <Widget>[
                  const Center(
                    child: Text(
                      'CUSTOMER – ITEM DETAIL',
                      style: TextStyle(
                        color: CustomerCheckoutTokens.mutedGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        const Text(
                          'Item Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: CustomerCheckoutTokens.ink,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: CustomerCheckoutTokens.primaryMaroon,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.ios_share_rounded,
                              color: CustomerCheckoutTokens.primaryMaroon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ItemHeroImage(imageUrl: item.imageUrl),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: CustomerCheckoutTokens.ink,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatPrice(item),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: CustomerCheckoutTokens.primaryMaroon,
                        ),
                      ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF6B5E58),
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: CustomerCheckoutTokens.fieldFill,
                      borderRadius: BorderRadius.circular(CustomerCheckoutTokens.cardRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: CustomerCheckoutTokens.ink,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'HOW MANY SERVINGS?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: CustomerCheckoutTokens.mutedGray,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomerQuantitySelector(
                            quantity: _quantity,
                            onDecrement: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            onIncrement: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Special Instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: CustomerCheckoutTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _instructions,
                    minLines: 4,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomerCheckoutTokens.ink,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'No onions? Extra sauce? Let us know here...',
                      hintStyle: TextStyle(
                        color: CustomerCheckoutTokens.mutedGray.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      filled: true,
                      fillColor: CustomerCheckoutTokens.fieldFill,
                      contentPadding: const EdgeInsets.all(16),
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
                        borderSide: const BorderSide(
                          color: CustomerCheckoutTokens.primaryMaroon,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(_horizontalPadding, 0, _horizontalPadding, 16),
              child: CustomerMaroonPrimaryButton(
                label: 'ADD TO CART',
                loading: _adding,
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemHeroImage extends StatelessWidget {
  const _ItemHeroImage({this.imageUrl});

  static const double _imageRadius = 20;

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl?.trim();
    final bool hasImage = url != null && url.isNotEmpty;

    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(_imageRadius),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: hasImage
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return _ItemImagePlaceholder();
                    },
                  )
                : const _ItemImagePlaceholder(),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.bolt_rounded, size: 14, color: CustomerCheckoutTokens.primaryMaroon),
                  SizedBox(width: 4),
                  Text(
                    "CHEF'S CHOICE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: CustomerCheckoutTokens.primaryMaroon,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemImagePlaceholder extends StatelessWidget {
  const _ItemImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: CustomerCheckoutTokens.fieldFill,
      child: Center(
        child: Icon(
          Icons.fastfood_rounded,
          size: 64,
          color: CustomerCheckoutTokens.mutedGray,
        ),
      ),
    );
  }
}
