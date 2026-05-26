import '../../../customer/orders/domain/order_models.dart';

export '../../../customer/orders/domain/order_models.dart' show DeliveryAddress, OrderLineItem;

final class DriverOrderSummary {
  const DriverOrderSummary({
    required this.id,
    required this.reference,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.deliveryFee,
    required this.driverPayout,
    required this.placedAt,
    required this.dropoffLine,
    this.driverAcknowledgedAt,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
  });

  final int id;
  final String reference;
  final String restaurantName;
  final String restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String customerName;
  final String status;
  final String totalAmount;
  final String deliveryFee;
  final String driverPayout;
  final String placedAt;
  final String dropoffLine;
  final String? driverAcknowledgedAt;

  factory DriverOrderSummary.fromJson(Map<String, dynamic> m) {
    final Map<String, dynamic> addr =
        m['delivery_address'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final String line = addr['address_line'] as String? ?? '';
    final String landmark = addr['landmark'] as String? ?? '';
    return DriverOrderSummary(
      id: m['id'] as int,
      reference: m['reference'] as String? ?? '',
      restaurantName: m['restaurant_name'] as String? ?? '',
      restaurantAddress: m['restaurant_address'] as String? ?? '',
      customerName: m['customer_name'] as String? ?? '',
      status: m['status'] as String? ?? '',
      totalAmount: '${m['total_amount']}',
      deliveryFee: '${m['delivery_fee']}',
      driverPayout: '${m['driver_payout'] ?? m['delivery_fee']}',
      placedAt: m['placed_at'] as String? ?? '',
      dropoffLine: landmark.isNotEmpty ? '$line · $landmark' : line,
      driverAcknowledgedAt: m['driver_acknowledged_at'] as String?,
      restaurantLatitude: _readDouble(m['restaurant_latitude']),
      restaurantLongitude: _readDouble(m['restaurant_longitude']),
      dropoffLatitude: _readDouble(addr['latitude']),
      dropoffLongitude: _readDouble(addr['longitude']),
    );
  }

  bool get isActive =>
      status != 'delivered' && status != 'cancelled' && status != 'declined';

  bool get needsAcknowledgment =>
      status == 'assigned' && (driverAcknowledgedAt == null || driverAcknowledgedAt!.isEmpty);

  bool get isPickupPhase => status == 'assigned' || status == 'picked_up';

  bool get isDeliveringPhase => status == 'delivering';
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
    required this.driverPayout,
    required this.totalAmount,
    required this.placedAt,
    required this.deliveryAddress,
    required this.items,
    this.customerNote = '',
    this.driverAcknowledgedAt,
    this.restaurantLatitude,
    this.restaurantLongitude,
  });

  final int id;
  final String reference;
  final String status;
  final String restaurantName;
  final String restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final String customerPhone;
  final String subtotal;
  final String deliveryFee;
  final String driverPayout;
  final String totalAmount;
  final String placedAt;
  final DeliveryAddress deliveryAddress;
  final List<OrderLineItem> items;
  /// Free-form note from the customer. At checkout the customer mobile
  /// joins each item's `specialInstructions` into this field as
  /// "<item name>: <instructions>" lines, so a non-empty value here is
  /// exactly the per-item special instructions the driver should see.
  final String customerNote;
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
      driverPayout: '${m['driver_payout'] ?? m['delivery_fee']}',
      totalAmount: '${m['total_amount']}',
      placedAt: m['placed_at'] as String? ?? '',
      customerNote: (m['customer_note'] as String? ?? '').trim(),
      driverAcknowledgedAt: m['driver_acknowledged_at'] as String?,
      restaurantLatitude: _readDouble(m['restaurant_latitude']),
      restaurantLongitude: _readDouble(m['restaurant_longitude']),
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

double? _readDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}
