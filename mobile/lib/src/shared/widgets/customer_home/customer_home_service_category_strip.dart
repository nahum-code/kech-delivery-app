import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

/// Home category filter strip. The first tile is always "Restaurant" (all
/// restaurants); the remaining tiles are menu-category names sourced from the
/// admin side (aggregated across restaurants).
class CustomerHomeServiceCategoryStrip extends StatelessWidget {
  const CustomerHomeServiceCategoryStrip({
    super.key,
    required this.categories,
    required this.selected,
    required this.onCategoryChanged,
  });

  /// Ordered category labels to render. Expected to start with [restaurantCategory].
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onCategoryChanged;

  /// The fixed "all restaurants" filter label.
  static const String restaurantCategory = 'Restaurant';

  static IconData _iconFor(String c) {
    if (c == restaurantCategory) return Icons.storefront_rounded;
    final String k = c.toLowerCase();
    if (k.contains('drink') || k.contains('beverage') || k.contains('juice')) {
      return Icons.local_drink_outlined;
    }
    if (k.contains('coffee') || k.contains('tea')) return Icons.coffee_outlined;
    if (k.contains('dessert') || k.contains('cake') || k.contains('sweet')) {
      return Icons.cake_outlined;
    }
    if (k.contains('breakfast')) return Icons.free_breakfast_outlined;
    if (k.contains('pizza')) return Icons.local_pizza_outlined;
    if (k.contains('burger')) return Icons.lunch_dining_outlined;
    if (k.contains('food') || k.contains('meal') || k.contains('dish')) {
      return Icons.restaurant_rounded;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          return _CategoryTile(
            label: category,
            icon: _iconFor(category),
            selected: selected == category,
            onTap: () => onCategoryChanged(category),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tileBg = selected ? CustomerHomeTokens.primaryMaroon : CustomerHomeTokens.categoryIdleSurface;
    final Color iconColor = selected ? Colors.white : CustomerHomeTokens.primaryMaroon;
    final Color labelColor = selected ? CustomerHomeTokens.primaryMaroon : CustomerHomeTokens.labelGray;

    return InkWell(
      borderRadius: BorderRadius.circular(CustomerHomeTokens.categoryTileRadius),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(CustomerHomeTokens.categoryTileRadius),
                boxShadow: selected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: CustomerHomeTokens.primaryMaroon.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
