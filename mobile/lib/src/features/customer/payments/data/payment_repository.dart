import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/http/api_error_message.dart';
import '../domain/payment_models.dart';
import 'payment_api.dart';

final class PaymentRepository {
  PaymentRepository({required PaymentApi Function(String token) apiFactory}) : _apiFactory = apiFactory;

  final PaymentApi Function(String token) _apiFactory;

  Future<PaymentInitResult> initPayment({
    required String accessToken,
    required int orderId,
  }) async {
    final http.Response response = await _apiFactory(accessToken).initPayment(orderId);
    if (response.statusCode != 201) {
      throw _httpError(response, 'Could not start payment');
    }
    return PaymentInitResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PaymentRecord> verifyPayment({
    required String accessToken,
    int? orderId,
    String? txRef,
  }) async {
    final http.Response response = await _apiFactory(accessToken).verifyPayment(orderId: orderId, txRef: txRef);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not verify payment');
    }
    return PaymentRecord.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Exception _httpError(http.Response response, String fallback) {
    try {
      final dynamic body = jsonDecode(response.body);
      return Exception(parseApiErrorMessage(body, fallback));
    } catch (_) {}
    return Exception('$fallback (${response.statusCode})');
  }
}
