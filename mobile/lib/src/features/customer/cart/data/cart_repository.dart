import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cart_models.dart';

final class CartRepository extends ChangeNotifier {
  static const String _storageKey = 'customer_cart_v1';

  CartState? _cache;

  CartState? get current => _cache;

  Future<CartState?> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null) {
      _cache = null;
      return null;
    }
    final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
    _cache = _fromJson(m);
    notifyListeners();
    return _cache;
  }

  Future<void> save(CartState? cart) async {
    _cache = cart;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (cart == null) {
      await prefs.remove(_storageKey);
      return;
    }
    await prefs.setString(_storageKey, jsonEncode(_toJson(cart)));
  }

  Future<CartState> addItem({
    required int restaurantId,
    required String restaurantName,
    required CartLine line,
  }) async {
    CartState cart = _cache ??
        CartState(restaurantId: restaurantId, restaurantName: restaurantName, lines: <CartLine>[]);

    if (cart.restaurantId != restaurantId) {
      cart = CartState(restaurantId: restaurantId, restaurantName: restaurantName, lines: <CartLine>[]);
    }

    final List<CartLine> lines = List<CartLine>.from(cart.lines);
    final int index = lines.indexWhere((CartLine l) => l.menuItemId == line.menuItemId);
    if (index >= 0) {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + line.quantity);
    } else {
      lines.add(line);
    }
    cart = CartState(restaurantId: restaurantId, restaurantName: restaurantName, lines: lines);
    await save(cart);
    return cart;
  }

  Future<void> clear() => save(null);

  Map<String, dynamic> _toJson(CartState cart) => <String, dynamic>{
        'restaurant_id': cart.restaurantId,
        'restaurant_name': cart.restaurantName,
        'lines': cart.lines
            .map(
              (CartLine l) => <String, dynamic>{
                'menu_item_id': l.menuItemId,
                'name': l.name,
                'unit_price': l.unitPrice,
                'quantity': l.quantity,
                'image_url': l.imageUrl,
                'currency': l.currency,
              },
            )
            .toList(),
      };

  CartState _fromJson(Map<String, dynamic> m) {
    final List<dynamic> rawLines = m['lines'] as List<dynamic>? ?? <dynamic>[];
    return CartState(
      restaurantId: m['restaurant_id'] as int,
      restaurantName: m['restaurant_name'] as String? ?? '',
      lines: rawLines
          .map(
            (dynamic e) => CartLine(
              menuItemId: (e as Map<String, dynamic>)['menu_item_id'] as int,
              name: e['name'] as String? ?? '',
              unitPrice: '${e['unit_price']}',
              quantity: e['quantity'] as int? ?? 1,
              imageUrl: e['image_url'] as String?,
              currency: e['currency'] as String? ?? 'MAD',
            ),
          )
          .toList(growable: false),
    );
  }
}
