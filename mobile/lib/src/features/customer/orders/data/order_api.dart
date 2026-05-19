import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final class OrderApi {
  OrderApi({required String baseUrl, required this.accessToken, http.Client? httpClient})
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

  Future<http.Response> createOrder(Map<String, dynamic> body) {
    return _client.post(_u('/api/v1/orders/'), headers: _headers, body: jsonEncode(body));
  }

  Future<http.Response> myOrders({int page = 1}) {
    return _client.get(_u('/api/v1/orders/my/?page=$page'), headers: _headers);
  }

  Future<http.Response> orderDetail(int id) {
    return _client.get(_u('/api/v1/orders/$id/'), headers: _headers);
  }
}
