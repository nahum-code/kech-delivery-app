/// Local cart line before checkout.
final class CartLine {
  const CartLine({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.currency = 'MAD',
    this.subtitle = '',
    this.specialInstructions = '',
  });

  final int menuItemId;
  final String name;
  final String unitPrice;
  final int quantity;
  final String? imageUrl;
  final String currency;
  final String subtitle;
  final String specialInstructions;

  double get lineTotal => (double.tryParse(unitPrice) ?? 0) * quantity;

  CartLine copyWith({
    int? quantity,
    String? specialInstructions,
    String? subtitle,
  }) =>
      CartLine(
        menuItemId: menuItemId,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
        currency: currency,
        subtitle: subtitle ?? this.subtitle,
        specialInstructions: specialInstructions ?? this.specialInstructions,
      );
}

final class CartState {
  const CartState({required this.restaurantId, required this.restaurantName, required this.lines});

  final int restaurantId;
  final String restaurantName;
  final List<CartLine> lines;

  double get subtotal => lines.fold(0, (double s, CartLine l) => s + l.lineTotal);

  bool get isEmpty => lines.isEmpty;
}
