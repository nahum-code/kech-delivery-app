final class DeliveryAddress {
  const DeliveryAddress({
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    this.landmark = '',
  });

  final String receiverName;
  final String phone;
  final String addressLine;
  final String landmark;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'receiver_name': receiverName,
        'phone': phone,
        'address_line': addressLine,
        'landmark': landmark,
      };
}

final class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.reference,
    required this.restaurantName,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.placedAt,
  });

  final int id;
  final String reference;
  final String restaurantName;
  final String status;
  final String paymentStatus;
  final String totalAmount;
  final String placedAt;

  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isActiveForTracking =>
      status != 'delivered' && status != 'cancelled' && paymentStatus == 'paid';

  factory OrderSummary.fromJson(Map<String, dynamic> m) => OrderSummary(
        id: m['id'] as int,
        reference: m['reference'] as String? ?? '',
        restaurantName: m['restaurant_name'] as String? ?? '',
        status: m['status'] as String? ?? '',
        paymentStatus: m['payment_status'] as String? ?? 'pending',
        totalAmount: '${m['total_amount']}',
        placedAt: m['placed_at'] as String? ?? '',
      );
}

final class OrderLineItem {
  const OrderLineItem({
    required this.name,
    required this.quantity,
    required this.totalPrice,
    this.imageUrl,
  });

  final String name;
  final int quantity;
  final String totalPrice;
  final String? imageUrl;
}

final class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.reference,
    required this.status,
    required this.paymentStatus,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.placedAt,
    required this.deliveryAddress,
    required this.items,
  });

  final int id;
  final String reference;
  final String status;
  final String paymentStatus;
  final String restaurantName;
  final String restaurantAddress;
  final String subtotal;
  final String deliveryFee;
  final String totalAmount;
  final String placedAt;
  final DeliveryAddress deliveryAddress;
  final List<OrderLineItem> items;

  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';
  bool get isTerminal => status == 'delivered' || status == 'cancelled';

  factory OrderDetail.fromJson(Map<String, dynamic> m) {
    final Map<String, dynamic> addr = m['delivery_address'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> rawItems = m['items'] as List<dynamic>? ?? <dynamic>[];
    return OrderDetail(
      id: m['id'] as int,
      reference: m['reference'] as String? ?? '',
      status: m['status'] as String? ?? '',
      paymentStatus: m['payment_status'] as String? ?? 'pending',
      restaurantName: m['restaurant_name'] as String? ?? '',
      restaurantAddress: m['restaurant_address'] as String? ?? '',
      subtotal: '${m['subtotal']}',
      deliveryFee: '${m['delivery_fee']}',
      totalAmount: '${m['total_amount']}',
      placedAt: m['placed_at'] as String? ?? '',
      deliveryAddress: DeliveryAddress(
        receiverName: addr['receiver_name'] as String? ?? '',
        phone: addr['phone'] as String? ?? '',
        addressLine: addr['address_line'] as String? ?? '',
        landmark: addr['landmark'] as String? ?? '',
      ),
      items: rawItems
          .map(
            (dynamic e) {
              final Map<String, dynamic> item = e as Map<String, dynamic>;
              return OrderLineItem(
                name: item['item_name'] as String? ?? '',
                quantity: item['quantity'] as int? ?? 1,
                totalPrice: '${item['total_price']}',
                imageUrl: item['image_url'] as String?,
              );
            },
          )
          .toList(growable: false),
    );
  }
}
