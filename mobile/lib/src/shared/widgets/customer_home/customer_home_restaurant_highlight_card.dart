import 'package:flutter/material.dart';

import '../../contracts/customer_home_restaurant_preview.dart';
import '../../theme/customer_home_tokens.dart';
import 'customer_restaurant_preview_image.dart';

class CustomerHomeRestaurantHighlightCard extends StatelessWidget {
  const CustomerHomeRestaurantHighlightCard({
    super.key,
    required this.preview,
    this.width = 280,
    this.height,
    this.onTap,
  });

  final CustomerHomeRestaurantPreview preview;
  final double width;
  final double? height;
  final VoidCallback? onTap;

  static Widget _buildImage(CustomerHomeRestaurantPreview preview) {
    if (preview.imageUrl != null && preview.imageUrl!.isNotEmpty) {
      return Image.network(
        preview.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return _placeholder();
        },
      );
    }
    if (preview.imageAssetPath != null && preview.imageAssetPath!.isNotEmpty) {
      return Image.asset(
        preview.imageAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return _placeholder();
        },
      );
    }
    return _placeholder();
  }

  static Widget _placeholder() {
    return Center(
      child: Icon(Icons.storefront_rounded, size: 48, color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(CustomerHomeTokens.restaurantCardRadius),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CustomerHomeTokens.restaurantCardRadius),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CustomerRestaurantPreviewImage(
                  imageUrl: preview.imageUrl,
                  imageAssetPath: preview.imageAssetPath,
                ),
                if (preview.hasRating)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              preview.ratingValue.toStringAsFixed(1),
                              style: const TextStyle(
                                color: CustomerHomeTokens.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                      child: Text(
                        preview.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
