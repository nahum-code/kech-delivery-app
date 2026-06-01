import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final class DriverOrderApi {
  DriverOrderApi({required String baseUrl, required this.accessToken, http.Client? httpClient})
      : _base = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = httpClient ?? http.Client();

  final String _base;
  final http.Client _client;
  final String accessToken;

  Uri _u(String path) => Uri.parse('$_base$path');

  Map<String, String> get _headers => <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      };

  Future<http.Response> listOrders({String? status}) {
    final String path = status != null
        ? '/api/v1/drivers/orders/?status=$status'
        : '/api/v1/drivers/orders/';
    return _client.get(_u(path), headers: _headers);
  }

  Future<http.Response> orderDetail(int id) {
    return _client.get(_u('/api/v1/drivers/orders/$id/'), headers: _headers);
  }

  Future<http.Response> listAvailable() {
    return _client.get(_u('/api/v1/drivers/orders/available/'), headers: _headers);
  }

  Future<http.Response> availableDetail(int id) {
    return _client.get(_u('/api/v1/drivers/orders/available/$id/'), headers: _headers);
  }

  Future<http.Response> claim(int id) {
    return _client.post(_u('/api/v1/drivers/orders/$id/claim/'), headers: _headers);
  }

  Future<http.Response> accept(int id) {
    return _client.post(_u('/api/v1/drivers/orders/$id/accept/'), headers: _headers);
  }

  Future<http.Response> decline(int id) {
    return _client.post(_u('/api/v1/drivers/orders/$id/decline/'), headers: _headers);
  }

  Future<http.Response> pickup(int id) {
    return _client.post(_u('/api/v1/drivers/orders/$id/pickup/'), headers: _headers);
  }

  Future<http.Response> startDelivery(int id) {
    return _client.post(_u('/api/v1/drivers/orders/$id/start-delivery/'), headers: _headers);
  }

  Future<http.Response> complete(int id) {
    return _client.post(_u('/api/v1/drivers/orders/$id/complete/'), headers: _headers);
  }

  Future<http.Response> availability() {
    return _client.get(_u('/api/v1/drivers/me/availability/'), headers: _headers);
  }

  Future<http.Response> setAvailability(String operationalStatus) {
    return _client.patch(
      _u('/api/v1/drivers/me/availability/'),
      headers: _headers,
      body: jsonEncode(<String, String>{'operational_status': operationalStatus}),
    );
  }

  Future<http.Response> driverStatus() {
    return _client.get(_u('/api/v1/drivers/me/status/'), headers: _headers);
  }

  Future<http.Response> myBalance() {
    return _client.get(_u('/api/v1/drivers/me/balance/'), headers: _headers);
  }
}
