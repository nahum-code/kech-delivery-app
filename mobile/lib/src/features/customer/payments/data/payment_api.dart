import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final class PaymentApi {
  PaymentApi({required String baseUrl, required this.accessToken, http.Client? httpClient})
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

  Future<http.Response> initPayment(int orderId) {
    return _client.post(
      _u('/api/v1/payments/init/'),
      headers: _headers,
      body: jsonEncode(<String, dynamic>{'order_id': orderId}),
    );
  }

  Future<http.Response> verifyPayment({int? orderId, String? txRef}) {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (orderId != null) body['order_id'] = orderId;
    if (txRef != null) body['tx_ref'] = txRef;
    return _client.post(
      _u('/api/v1/payments/verify/'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }
}
