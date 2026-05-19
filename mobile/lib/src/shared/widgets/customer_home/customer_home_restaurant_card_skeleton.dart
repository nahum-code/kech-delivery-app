import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeRestaurantCardSkeleton extends StatelessWidget {
  const CustomerHomeRestaurantCardSkeleton({super.key, required this.width, this.height = 200});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CustomerHomeTokens.restaurantCardRadius),
        child: ColoredBox(
          color: CustomerHomeTokens.searchFill,
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ),
      ),
    );
  }
}
