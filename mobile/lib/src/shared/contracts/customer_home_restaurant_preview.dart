class CustomerHomeRestaurantPreview {
  const CustomerHomeRestaurantPreview({
    required this.id,
    required this.displayName,
    required this.imageAssetPath,
    required this.ratingValue,
  });

  final String id;
  final String displayName;
  final String imageAssetPath;
  final double ratingValue;
}
