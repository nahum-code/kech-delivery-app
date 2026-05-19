import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Public restaurant catalog (`/api/v1/restaurants/`).
final class RestaurantApi {
  RestaurantApi({
    required String baseUrl,
    http.Client? httpClient,
  })  : _base = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = httpClient ?? http.Client();

  final String _base;
  final http.Client _client;

  Uri _u(String path) => Uri.parse('$_base$path');

  Future<http.Response> listRestaurants({String? search}) {
    final Uri uri = search != null && search.trim().isNotEmpty
        ? _u('/api/v1/restaurants/').replace(queryParameters: <String, String>{'search': search.trim()})
        : _u('/api/v1/restaurants/');
    return _client.get(uri, headers: _jsonHeaders);
  }

  Future<http.Response> restaurantDetail(int id) {
    return _client.get(_u('/api/v1/restaurants/$id/'), headers: _jsonHeaders);
  }

  Future<http.Response> restaurantMenu(int id) {
    return _client.get(_u('/api/v1/restaurants/$id/menu/'), headers: _jsonHeaders);
  }

  static const Map<String, String> _jsonHeaders = <String, String>{
    HttpHeaders.acceptHeader: 'application/json',
  };
}
