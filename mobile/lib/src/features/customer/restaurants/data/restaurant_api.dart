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

  Future<http.Response> listRestaurants({String? search, String? category}) {
    final Map<String, String> query = <String, String>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (category != null && category.trim().isNotEmpty) 'category': category.trim(),
    };
    final Uri uri = query.isEmpty
        ? _u('/api/v1/restaurants/')
        : _u('/api/v1/restaurants/').replace(queryParameters: query);
    return _client.get(uri, headers: _jsonHeaders);
  }

  /// Distinct active menu-category names across restaurants (public).
  Future<http.Response> listMenuCategories() {
    return _client.get(_u('/api/v1/restaurants/menu-categories/'), headers: _jsonHeaders);
  }

  /// Available menu items across restaurants, optionally one category (public).
  Future<http.Response> listMenuItems({String? category}) {
    final Uri uri = category != null && category.trim().isNotEmpty
        ? _u('/api/v1/restaurants/menu-items/')
            .replace(queryParameters: <String, String>{'category': category.trim()})
        : _u('/api/v1/restaurants/menu-items/');
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
