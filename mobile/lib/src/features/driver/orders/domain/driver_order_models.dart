import '../../../customer/orders/domain/order_models.dart';

export '../../../customer/orders/domain/order_models.dart' show DeliveryAddress, OrderLineItem;

final class DriverOrderSummary {
  const DriverOrderSummary({
    required this.id,
    required this.reference,
    required this.restaurantName,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.placedAt,
  });

  final int id;
  final String reference;
  final String restaurantName;
  final String customerName;
  final String status;
  final String totalAmount;
  final String placedAt;

  factory DriverOrderSummary.fromJson(Map<String, dynamic> m) => DriverOrderSummary(
        id: m['id'] as int,
        reference: m['reference'] as String? ?? '',
        restaurantName: m['restaurant_name'] as String? ?? '',
        customerName: m['customer_name'] as String? ?? '',
        status: m['status'] as String? ?? '',
        totalAmount: '${m['total_amount']}',
        placedAt: m['placed_at'] as String? ?? '',
      );

  bool get isActive =>
      status != 'delivered' && status != 'cancelled';
}

final class DriverOrderDetail {
  const DriverOrderDetail({
    required this.id,
    required this.reference,
    required this.status,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerPhone,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.placedAt,
    required this.deliveryAddress,
    required this.items,
    this.driverAcknowledgedAt,
  });

  final int id;
  final String reference;
  final String status;
  final String restaurantName;
  final String restaurantAddress;
  final String customerPhone;
  final String subtotal;
  final String deliveryFee;
  final String totalAmount;
  final String placedAt;
  final DeliveryAddress deliveryAddress;
  final List<OrderLineItem> items;
  final String? driverAcknowledgedAt;

  factory DriverOrderDetail.fromJson(Map<String, dynamic> m) {
    final Map<String, dynamic> addr =
        m['delivery_address'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> rawItems = m['items'] as List<dynamic>? ?? <dynamic>[];
    return DriverOrderDetail(
      id: m['id'] as int,
      reference: m['reference'] as String? ?? '',
      status: m['status'] as String? ?? '',
      restaurantName: m['restaurant_name'] as String? ?? '',
      restaurantAddress: m['restaurant_address'] as String? ?? '',
      customerPhone: m['customer_phone'] as String? ?? '',
      subtotal: '${m['subtotal']}',
      deliveryFee: '${m['delivery_fee']}',
      totalAmount: '${m['total_amount']}',
      placedAt: m['placed_at'] as String? ?? '',
      driverAcknowledgedAt: m['driver_acknowledged_at'] as String?,
      deliveryAddress: DeliveryAddress(
        receiverName: addr['receiver_name'] as String? ?? '',
        phone: addr['phone'] as String? ?? '',
        addressLine: addr['address_line'] as String? ?? '',
        landmark: addr['landmark'] as String? ?? '',
      ),
      items: rawItems
          .map(
            (dynamic e) => OrderLineItem(
              name: (e as Map<String, dynamic>)['item_name'] as String? ?? '',
              quantity: e['quantity'] as int? ?? 0,
              totalPrice: '${e['total_price']}',
              imageUrl: e['image_url'] as String?,
            ),
          )
          .toList(),
    );
  }
}

final class DriverAvailability {
  const DriverAvailability({
    required this.operationalStatus,
    required this.activeDeliveryCount,
  });

  final String operationalStatus;
  final int activeDeliveryCount;

  factory DriverAvailability.fromJson(Map<String, dynamic> m) => DriverAvailability(
        operationalStatus: m['operational_status'] as String? ?? 'offline',
        activeDeliveryCount: m['active_delivery_count'] as int? ?? 0,
      );

  bool get isOnline => operationalStatus == 'online' || operationalStatus == 'busy';
}
