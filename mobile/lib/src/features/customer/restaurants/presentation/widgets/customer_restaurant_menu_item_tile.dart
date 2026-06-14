import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_restaurant_preview_image.dart';
import '../../domain/restaurant_models.dart';

class CustomerRestaurantMenuItemTile extends StatelessWidget {
  const CustomerRestaurantMenuItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  final PublicMenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(CustomerHomeTokens.restaurantCardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: CustomerRestaurantPreviewImage(
                    imageUrl: item.imageUrl,
                    placeholderIconSize: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: CustomerHomeTokens.ink,
                        height: 1.2,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomerHomeTokens.labelGray,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${item.price} ${item.currency}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: CustomerHomeTokens.primaryMaroon,
                      ),
                    ),
                    if ((double.tryParse(item.takeawayBoxPrice) ?? 0) > 0) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        '+ ${item.takeawayBoxPrice} ${item.currency} box',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: CustomerHomeTokens.labelGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: CustomerHomeTokens.primaryMaroon,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAdd,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
