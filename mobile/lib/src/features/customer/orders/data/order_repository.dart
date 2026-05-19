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
  }) async {
    final http.Response response = await _apiFactory(accessToken).createOrder(<String, dynamic>{
      'restaurant_id': cart.restaurantId,
      'items': cart.lines
          .map((CartLine l) => <String, dynamic>{'menu_item_id': l.menuItemId, 'quantity': l.quantity})
          .toList(),
      'delivery_address': address.toJson(),
      'customer_note': customerNote,
    });
    if (response.statusCode != 201) {
      throw _httpError(response, 'Could not place order');
    }
    return OrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<OrderSummary>> fetchMyOrders({required String accessToken}) async {
    final http.Response response = await _apiFactory(accessToken).myOrders();
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load orders');
    }
    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> results = body['results'] as List<dynamic>? ?? <dynamic>[];
    return results.map((dynamic e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList();
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
