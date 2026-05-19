class CustomerHomeRestaurantPreview {
  const CustomerHomeRestaurantPreview({
    required this.id,
    required this.displayName,
    this.imageAssetPath,
    this.imageUrl,
    this.ratingValue = 0,
  }) : assert(
          imageAssetPath != null || imageUrl != null,
          'Provide imageAssetPath and/or imageUrl',
        );

  final String id;
  final String displayName;
  final String? imageAssetPath;
  final String? imageUrl;
  final double ratingValue;

  bool get hasRating => ratingValue > 0;
}
