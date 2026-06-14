final class DeliveryAddress {
  const DeliveryAddress({
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    this.landmark = '',
    this.latitude,
    this.longitude,
  });

  final String receiverName;
  final String phone;
  final String addressLine;
  final String landmark;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'receiver_name': receiverName,
        'phone': phone,
        'address_line': addressLine,
        'landmark': landmark,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

final class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.reference,
    required this.restaurantName,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.placedAt,
  });

  final int id;
  final String reference;
  final String restaurantName;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String totalAmount;
  final String placedAt;

  bool get isPaymentPending => paymentStatus == 'pending';

  /// Pay-on-delivery orders are collected by the driver, not paid in-app — so
  /// a pending payment status is expected and must not trigger online-payment UI.
  bool get isPayOnDelivery => paymentMethod == 'pod';

  /// True only when the customer still needs to complete an online (Chapa)
  /// payment. POD orders are never "awaiting online payment".
  bool get isAwaitingOnlinePayment => paymentStatus == 'pending' && !isPayOnDelivery;

  bool get isActiveForTracking =>
      status != 'delivered' &&
      status != 'cancelled' &&
      (isPayOnDelivery || paymentStatus == 'paid');

  factory OrderSummary.fromJson(Map<String, dynamic> m) => OrderSummary(
        id: m['id'] as int,
        reference: m['reference'] as String? ?? '',
        restaurantName: m['restaurant_name'] as String? ?? '',
        status: m['status'] as String? ?? '',
        paymentStatus: m['payment_status'] as String? ?? 'pending',
        paymentMethod: m['payment_method'] as String? ?? 'chapa',
        totalAmount: '${m['total_amount']}',
        placedAt: m['placed_at'] as String? ?? '',
      );
}

final class DeliveryFeeQuote {
  const DeliveryFeeQuote({
    required this.distanceKm,
    required this.driverPayout,
    required this.platformFee,
    required this.deliveryFee,
  });

  final String? distanceKm;
  final String driverPayout;
  final String platformFee;
  final String deliveryFee;
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

double? _readDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

final class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.reference,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.restaurantName,
    required this.restaurantAddress,
    this.restaurantLatitude,
    this.restaurantLongitude,
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
  final String paymentMethod;
  final String restaurantName;
  final String restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final String subtotal;
  final String deliveryFee;
  final String totalAmount;
  final String placedAt;
  final DeliveryAddress deliveryAddress;
  final List<OrderLineItem> items;

  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';

  /// Pay-on-delivery orders are collected by the driver, not paid in-app.
  bool get isPayOnDelivery => paymentMethod == 'pod';

  /// True only when the customer still needs to complete an online (Chapa)
  /// payment. POD orders are never "awaiting online payment".
  bool get isAwaitingOnlinePayment => paymentStatus == 'pending' && !isPayOnDelivery;

  bool get isTerminal => status == 'delivered' || status == 'cancelled';

  factory OrderDetail.fromJson(Map<String, dynamic> m) {
    final Map<String, dynamic> addr = m['delivery_address'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> rawItems = m['items'] as List<dynamic>? ?? <dynamic>[];
    return OrderDetail(
      id: m['id'] as int,
      reference: m['reference'] as String? ?? '',
      status: m['status'] as String? ?? '',
      paymentStatus: m['payment_status'] as String? ?? 'pending',
      paymentMethod: m['payment_method'] as String? ?? 'chapa',
      restaurantName: m['restaurant_name'] as String? ?? '',
      restaurantAddress: m['restaurant_address'] as String? ?? '',
      restaurantLatitude: _readDouble(m['restaurant_latitude']),
      restaurantLongitude: _readDouble(m['restaurant_longitude']),
      subtotal: '${m['subtotal']}',
      deliveryFee: '${m['delivery_fee']}',
      totalAmount: '${m['total_amount']}',
      placedAt: m['placed_at'] as String? ?? '',
      deliveryAddress: DeliveryAddress(
        receiverName: addr['receiver_name'] as String? ?? '',
        phone: addr['phone'] as String? ?? '',
        addressLine: addr['address_line'] as String? ?? '',
        landmark: addr['landmark'] as String? ?? '',
        latitude: _readDouble(addr['latitude']),
        longitude: _readDouble(addr['longitude']),
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
