import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../cart/domain/cart_models.dart';
import '../domain/order_models.dart';
import 'order_api.dart';

final class OrderRepository {
  OrderRepository({required OrderApi Function(String token) apiFactory})
      : _apiFactory = apiFactory;

  final OrderApi Function(String token) _apiFactory;

  Future<OrderDetail> placeOrder({
    required String accessToken,
    required CartState cart,
    required DeliveryAddress address,
    String customerNote = '',
    String paymentMethod = 'chapa',
  }) async {
    final http.Response response = await _apiFactory(accessToken).createOrder(<String, dynamic>{
      'restaurant_id': cart.restaurantId,
      'items': cart.lines
          .map((CartLine l) => <String, dynamic>{'menu_item_id': l.menuItemId, 'quantity': l.quantity})
          .toList(),
      'delivery_address': address.toJson(),
      'customer_note': customerNote,
      'payment_method': paymentMethod,
    });
    if (response.statusCode != 201) {
      throw _httpError(response, 'Could not place order');
    }
    return OrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Fetch every order in this customer's history by walking the paginated
  /// `/my/` endpoint until `next` is null. Uses the max DRF page size (100)
  /// to keep round trips minimal.
  Future<List<OrderSummary>> fetchMyOrders({required String accessToken}) async {
    final List<OrderSummary> all = <OrderSummary>[];
    int page = 1;
    while (true) {
      final http.Response response =
          await _apiFactory(accessToken).myOrders(page: page);
      if (response.statusCode != 200) {
        throw _httpError(response, 'Could not load orders');
      }
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = body['results'] as List<dynamic>? ?? <dynamic>[];
      all.addAll(
        results.map((dynamic e) => OrderSummary.fromJson(e as Map<String, dynamic>)),
      );
      if (body['next'] == null) return all;
      page += 1;
    }
  }

  Future<OrderDetail> fetchOrderDetail({required String accessToken, required int orderId}) async {
    final http.Response response = await _apiFactory(accessToken).orderDetail(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load order');
    }
    return OrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<OrderDetail> confirmPayment({required String accessToken, required int orderId}) async {
    final http.Response response = await _apiFactory(accessToken).confirmPayment(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not confirm payment');
    }
    return OrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DeliveryFeeQuote> quoteDeliveryFee({
    required String accessToken,
    required int restaurantId,
    required double latitude,
    required double longitude,
  }) async {
    final http.Response response = await _apiFactory(accessToken).quoteDeliveryFee(
      restaurantId: restaurantId,
      latitude: latitude,
      longitude: longitude,
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not fetch delivery fee');
    }
    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    return DeliveryFeeQuote(
      distanceKm: body['distance_km'] as String?,
      driverPayout: '${body['driver_payout']}',
      platformFee: '${body['platform_fee']}',
      deliveryFee: '${body['delivery_fee']}',
    );
  }

  Exception _httpError(http.Response response, String fallback) {
    try {
      final dynamic body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['detail'] != null) {
        return Exception('${body['detail']}');
      }
    } catch (_) {}
    return Exception('$fallback (${response.statusCode})');
  }
}
