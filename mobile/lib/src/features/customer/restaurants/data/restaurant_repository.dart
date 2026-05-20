import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/restaurant_models.dart';
import 'restaurant_api.dart';

final class RestaurantRepository {
  RestaurantRepository({required RestaurantApi api}) : _api = api;

  final RestaurantApi _api;

  Future<RestaurantDetail> fetchRestaurantDetail(int restaurantId) async {
    final http.Response response = await _api.restaurantDetail(restaurantId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load restaurant');
    }
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected restaurant response');
    }
    return RestaurantDetail.fromJson(decoded);
  }

  Future<List<RestaurantSummary>> fetchActiveRestaurants({String? search}) async {
    final http.Response response = await _api.listRestaurants(search: search);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load restaurants');
    }
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Unexpected restaurants response');
    }
    return decoded.map(_parseRestaurant).toList(growable: false);
  }

  Future<RestaurantMenu> fetchMenu(int restaurantId) async {
    final http.Response response = await _api.restaurantMenu(restaurantId);
    if (response.statusCode != 200) {
      throw _httpError(response, 'Could not load menu');
    }
    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected menu response');
    }
    final List<dynamic> categories = decoded['categories'] as List<dynamic>? ?? <dynamic>[];
    final int? parsedRestaurantId = _readInt(decoded['restaurant_id']);
    if (parsedRestaurantId == null) {
      throw const FormatException('Menu response missing restaurant_id');
    }
    return RestaurantMenu(
      restaurantId: parsedRestaurantId,
      restaurantName: decoded['restaurant_name'] as String? ?? '',
      categories: categories.map(_parseCategory).toList(growable: false),
    );
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  RestaurantSummary _parseRestaurant(dynamic raw) {
    final Map<String, dynamic> m = raw as Map<String, dynamic>;
    final int? id = _readInt(m['id']);
    if (id == null) {
      throw const FormatException('Restaurant id is missing');
    }
    return RestaurantSummary(
      id: id,
      name: m['name'] as String? ?? '',
      description: m['description'] as String? ?? '',
      logoUrl: m['logo_url'] as String?,
      coverImageUrl: m['cover_image_url'] as String?,
      menuItemCount: m['menu_item_count'] as int? ?? 0,
    );
  }

  PublicMenuCategory _parseCategory(dynamic raw) {
    final Map<String, dynamic> m = raw as Map<String, dynamic>;
    final List<dynamic> items = m['items'] as List<dynamic>? ?? <dynamic>[];
    return PublicMenuCategory(
      id: m['id'] as int,
      name: m['name'] as String? ?? '',
      items: items.map(_parseItem).toList(growable: false),
    );
  }

  PublicMenuItem _parseItem(dynamic raw) {
    final Map<String, dynamic> m = raw as Map<String, dynamic>;
    final int? id = _readInt(m['id']);
    if (id == null) {
      throw const FormatException('Menu item id is missing');
    }
    return PublicMenuItem(
      id: id,
      name: m['name'] as String? ?? '',
      description: m['description'] as String? ?? '',
      price: '${m['price']}',
      currency: m['currency'] as String? ?? 'ETB',
      imageUrl: m['image_url'] as String?,
    );
  }

  Exception _httpError(http.Response response, String fallback) {
    try {
      final dynamic body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final dynamic detail = body['detail'] ?? body['message'];
        if (detail is String && detail.isNotEmpty) {
          return Exception(detail);
        }
      }
    } catch (_) {}
    return Exception('$fallback (${response.statusCode})');
  }
}
