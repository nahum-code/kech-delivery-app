class CustomerHomeRestaurantPreview {
  const CustomerHomeRestaurantPreview({
    required this.id,
    required this.displayName,
    this.imageAssetPath,
    this.imageUrl,
    this.ratingValue = 0,
  });

  final String id;
  final String displayName;
  final String? imageAssetPath;
  final String? imageUrl;
  final double ratingValue;

  bool get hasRating => ratingValue > 0;

  bool get hasImage {
    final String? url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return true;
    }
    final String? asset = imageAssetPath?.trim();
    return asset != null && asset.isNotEmpty;
  }
}
