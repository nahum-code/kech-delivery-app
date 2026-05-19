import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

/// Shared restaurant image / placeholder used on home cards and menu screens.
class CustomerRestaurantPreviewImage extends StatelessWidget {
  const CustomerRestaurantPreviewImage({
    super.key,
    this.imageUrl,
    this.imageAssetPath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIconSize = 48,
  });

  final String? imageUrl;
  final String? imageAssetPath;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double placeholderIconSize;

  static Widget placeholder({double iconSize = 48}) {
    return ColoredBox(
      color: CustomerHomeTokens.searchFill,
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: iconSize,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = _buildContent();
    if (borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _buildContent() {
    final String? url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return placeholder(iconSize: placeholderIconSize);
        },
      );
    }
    final String? asset = imageAssetPath?.trim();
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        fit: fit,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return placeholder(iconSize: placeholderIconSize);
        },
      );
    }
    return placeholder(iconSize: placeholderIconSize);
  }
}
