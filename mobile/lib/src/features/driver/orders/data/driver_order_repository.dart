import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/driver_order_models.dart';
import 'driver_order_api.dart';

final class DriverOrderRepository {
  DriverOrderRepository({required DriverOrderApi Function(String token) apiFactory})
      : _apiFactory = apiFactory;

  final DriverOrderApi Function(String token) _apiFactory;

  Future<List<DriverOrderSummary>> fetchOrders({
    required String accessToken,
    String? status,
  }) async {
    final http.Response response = await _apiFactory(accessToken).listOrders(status: status);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load deliveries');
    }
    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> results = body['results'] as List<dynamic>? ?? <dynamic>[];
    return results
        .map((dynamic e) => DriverOrderSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DriverOrderDetail> fetchOrderDetail({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).orderDetail(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> accept({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).accept(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not accept delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> pickup({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).pickup(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not mark picked up');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> startDelivery({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).startDelivery(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not start delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> complete({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).complete(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not complete delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverAvailability> fetchAvailability({required String accessToken}) async {
    final http.Response response = await _apiFactory(accessToken).availability();
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load availability');
    }
    return DriverAvailability.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverAvailability> setOnline({
    required String accessToken,
    required bool online,
  }) async {
    final http.Response response = await _apiFactory(accessToken).setAvailability(
      online ? 'online' : 'offline',
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not update availability');
    }
    return DriverAvailability.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> fetchDriverStatus({required String accessToken}) async {
    final http.Response response = await _apiFactory(accessToken).driverStatus();
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load profile');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
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
