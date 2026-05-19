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
