import '../../../../shared/contracts/customer_home_restaurant_preview.dart';

/// Customer-facing restaurant catalog models (API-aligned).
final class RestaurantSummary {
  const RestaurantSummary({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.menuItemCount = 0,
  });

  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverImageUrl;
  final int menuItemCount;

  String? get heroImageUrl => coverImageUrl ?? logoUrl;

  CustomerHomeRestaurantPreview toPreview() => CustomerHomeRestaurantPreview(
        id: '$id',
        displayName: name,
        imageUrl: heroImageUrl,
      );
}

/// Full restaurant row from `GET /api/v1/restaurants/{id}/`.
final class RestaurantDetail {
  const RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.menuItemCount = 0,
    this.phone = '',
    this.addressText = '',
    this.openingHours = '',
    this.isActive = true,
  });

  final int id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? coverImageUrl;
  final int menuItemCount;
  final String phone;
  final String addressText;
  final String openingHours;
  final bool isActive;

  String? get heroImageUrl => coverImageUrl ?? logoUrl;

  factory RestaurantDetail.fromJson(Map<String, dynamic> m) {
    final int? id = _readInt(m['id']);
    if (id == null) {
      throw const FormatException('Restaurant id is missing');
    }
    return RestaurantDetail(
      id: id,
      name: m['name'] as String? ?? '',
      description: m['description'] as String? ?? '',
      logoUrl: _readString(m['logo_url']),
      coverImageUrl: _readString(m['cover_image_url']),
      menuItemCount: _readInt(m['menu_item_count']) ?? 0,
      phone: m['phone'] as String? ?? '',
      addressText: m['address_text'] as String? ?? '',
      openingHours: _readString(m['opening_hours']) ?? '',
      isActive: m['is_active'] as bool? ?? true,
    );
  }

  RestaurantSummary toSummary() => RestaurantSummary(
        id: id,
        name: name,
        description: description,
        logoUrl: logoUrl,
        coverImageUrl: coverImageUrl,
        menuItemCount: menuItemCount,
      );
}

final class PublicMenuItem {
  const PublicMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final String price;
  final String currency;
  final String? imageUrl;
}

final class PublicMenuCategory {
  const PublicMenuCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  final int id;
  final String name;
  final List<PublicMenuItem> items;
}

final class RestaurantMenu {
  const RestaurantMenu({
    required this.restaurantId,
    required this.restaurantName,
    required this.categories,
  });

  final int restaurantId;
  final String restaurantName;
  final List<PublicMenuCategory> categories;
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

String? _readString(dynamic value) {
  if (value == null) {
    return null;
  }
  final String text = '$value'.trim();
  return text.isEmpty ? null : text;
}
