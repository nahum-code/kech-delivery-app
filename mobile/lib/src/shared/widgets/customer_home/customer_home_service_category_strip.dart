import 'package:flutter/material.dart';

import '../../contracts/customer_home_service_category.dart';
import '../../theme/customer_home_tokens.dart';

class CustomerHomeServiceCategoryStrip extends StatelessWidget {
  const CustomerHomeServiceCategoryStrip({
    super.key,
    required this.selected,
    required this.onCategoryChanged,
  });

  final CustomerHomeServiceCategory selected;
  final ValueChanged<CustomerHomeServiceCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _CategoryTile(category: CustomerHomeServiceCategory.food, selected: selected, onTap: onCategoryChanged)),
        const SizedBox(width: 10),
        Expanded(child: _CategoryTile(category: CustomerHomeServiceCategory.grocery, selected: selected, onTap: onCategoryChanged)),
        const SizedBox(width: 10),
        Expanded(child: _CategoryTile(category: CustomerHomeServiceCategory.pharmacy, selected: selected, onTap: onCategoryChanged)),
        const SizedBox(width: 10),
        Expanded(child: _CategoryTile(category: CustomerHomeServiceCategory.courier, selected: selected, onTap: onCategoryChanged)),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CustomerHomeServiceCategory category;
  final CustomerHomeServiceCategory selected;
  final ValueChanged<CustomerHomeServiceCategory> onTap;

  static IconData _iconFor(CustomerHomeServiceCategory c) {
    switch (c) {
      case CustomerHomeServiceCategory.food:
        return Icons.restaurant_rounded;
      case CustomerHomeServiceCategory.grocery:
        return Icons.shopping_basket_outlined;
      case CustomerHomeServiceCategory.pharmacy:
        return Icons.medical_services_outlined;
      case CustomerHomeServiceCategory.courier:
        return Icons.local_shipping_outlined;
    }
  }

  static String _labelFor(CustomerHomeServiceCategory c) {
    switch (c) {
      case CustomerHomeServiceCategory.food:
        return 'Food';
      case CustomerHomeServiceCategory.grocery:
        return 'Grocery';
      case CustomerHomeServiceCategory.pharmacy:
        return 'Pharmacy';
      case CustomerHomeServiceCategory.courier:
        return 'Courier';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOn = selected == category;
    final Color tileBg = isOn ? CustomerHomeTokens.primaryMaroon : CustomerHomeTokens.categoryIdleSurface;
    final Color iconColor = isOn ? Colors.white : CustomerHomeTokens.primaryMaroon;
    final Color labelColor = isOn ? CustomerHomeTokens.primaryMaroon : CustomerHomeTokens.labelGray;

    return InkWell(
      borderRadius: BorderRadius.circular(CustomerHomeTokens.categoryTileRadius),
      onTap: () => onTap(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(CustomerHomeTokens.categoryTileRadius),
                boxShadow: isOn
                    ? <BoxShadow>[
                        BoxShadow(
                          color: CustomerHomeTokens.primaryMaroon.withOpacity(0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(_iconFor(category), color: iconColor, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _labelFor(category),
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
