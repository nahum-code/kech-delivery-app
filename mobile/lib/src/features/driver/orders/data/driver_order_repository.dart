import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../auth/data/auth_repository.dart';
import '../../../../core/http/api_error_message.dart';
import '../domain/driver_order_models.dart';
import 'driver_order_api.dart';

class OrderTakenException implements Exception {
  const OrderTakenException();
  @override
  String toString() => 'Order is no longer available.';
}

final class DriverOrderRepository {
  DriverOrderRepository({
    required DriverOrderApi Function(String token) apiFactory,
    AuthRepository? authRepository,
  })  : _apiFactory = apiFactory,
        _auth = authRepository;

  final DriverOrderApi Function(String token) _apiFactory;
  final AuthRepository? _auth;

  Future<List<DriverOrderSummary>> fetchOrders({
    required String accessToken,
    String? status,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).listOrders(status: status),
    );
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
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).orderDetail(orderId),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> accept({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).accept(orderId),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not accept delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> decline({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).decline(orderId),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not decline delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> fetchAvailableDetail({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).availableDetail(orderId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load offer detail');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<DriverOrderSummary>> fetchAvailable({required String accessToken}) async {
    final http.Response response = await _apiFactory(accessToken).listAvailable();
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load new requests');
    }
    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> results = body['results'] as List<dynamic>? ?? <dynamic>[];
    return results
        .map((dynamic e) => DriverOrderSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// First-accept-wins claim. Throws [OrderTakenException] **only** when the
  /// server's detail confirms the order is genuinely gone (someone else won
  /// or status moved off SEARCHING_DRIVER). Other 409s — e.g. the driver
  /// hit their active-delivery cap — surface their real reason so the
  /// driver can react correctly instead of chasing an imaginary race.
  Future<DriverOrderDetail> claim({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).claim(orderId);
    if (response.statusCode == 409) {
      final String? detail = _readDetail(response.body);
      if (detail != null && detail.toLowerCase().contains('no longer available')) {
        throw const OrderTakenException();
      }
      throw Exception(detail ?? 'Could not accept request (409)');
    }
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not accept request');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> pickup({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).pickup(orderId),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not mark picked up');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> startDelivery({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).startDelivery(orderId),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not start delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverOrderDetail> complete({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).complete(orderId),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not complete delivery');
    }
    return DriverOrderDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverAvailability> fetchAvailability({required String accessToken}) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).availability(),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load availability');
    }
    return DriverAvailability.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<DriverAvailability> setOnline({
    required String accessToken,
    required bool online,
  }) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).setAvailability(
        online ? 'online' : 'offline',
      ),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not update availability');
    }
    return DriverAvailability.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> fetchDriverStatus({required String accessToken}) async {
    final http.Response response = await _request(
      accessToken,
      (String token) => _apiFactory(token).driverStatus(),
    );
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load profile');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Run [call] with the given access token, transparently retrying once
  /// with a refreshed token if the server returns 401. Mirrors the helper
  /// main introduced so all driver endpoints survive a stale access token.
  Future<http.Response> _request(
    String accessToken,
    Future<http.Response> Function(String token) call,
  ) async {
    http.Response response = await call(accessToken);
    if (response.statusCode == 401 && _auth != null) {
      final String? refreshed = await _auth.refreshAccessToken();
      if (refreshed != null) {
        response = await call(refreshed);
      }
    }
    return response;
  }

  Exception _httpError(http.Response response, String fallback) {
    final String? detail = _readDetail(response.body);
    if (detail != null) return Exception(detail);
    return Exception('$fallback (${response.statusCode})');
  }

  String? _readDetail(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } catch (_) {/* not JSON */}
    return null;
  }
}
