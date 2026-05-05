import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Thin REST client for `/api/v1/auth/*` (no business rules).
final class AuthApi {
  AuthApi({
    required String baseUrl,
    http.Client? httpClient,
  })  : _base = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = httpClient ?? http.Client();

  final String _base;
  final http.Client _client;

  Uri _u(String path) => Uri.parse('$_base$path');

  Future<http.Response> obtainToken({required String phone, required String password}) {
    return _client.post(
      _u('/api/v1/auth/token/'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{'phone': phone, 'password': password}),
    );
  }

  Future<http.Response> registerCustomer({
    required String phone,
    required String password,
    required String name,
  }) {
    return _client.post(
      _u('/api/v1/auth/register/customer'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{'phone': phone, 'password': password, 'name': name}),
    );
  }

  Future<http.Response> me({required String accessToken}) {
    return _client.get(
      _u('/api/v1/auth/me'),
      headers: <String, String>{
        ..._jsonHeaders,
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
    );
  }

  Future<http.Response> logout({
    required String accessToken,
    required String refreshToken,
  }) {
    return _client.post(
      _u('/api/v1/auth/logout'),
      headers: <String, String>{
        ..._jsonHeaders,
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{'refresh': refreshToken}),
    );
  }

  static const Map<String, String> _jsonHeaders = <String, String>{
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };
}
