import 'package:flutter/material.dart';

import '../../../../../shared/contracts/customer_home_restaurant_preview.dart';
import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_highlight_card.dart';
import '../../../../../shared/widgets/customer_home/customer_restaurant_preview_image.dart';
import '../../domain/restaurant_models.dart';

class CustomerRestaurantMenuHero extends StatelessWidget {
  const CustomerRestaurantMenuHero({
    super.key,
    required this.detail,
    required this.onBack,
    this.cartCount = 0,
    this.onCartPressed,
  });

  final RestaurantDetail detail;
  final VoidCallback onBack;
  final int cartCount;
  final VoidCallback? onCartPressed;

  bool get _hasHeroImage {
    final String? url = detail.heroImageUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double heroHeight = (width * 0.56).clamp(220.0, 280.0);
    final VoidCallback? cartPressed = onCartPressed;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (_hasHeroImage)
            CustomerRestaurantPreviewImage(imageUrl: detail.heroImageUrl)
          else
            Padding(
              padding: EdgeInsets.fromLTRB(18, MediaQuery.paddingOf(context).top + 52, 18, 12),
              child: CustomerHomeRestaurantHighlightCard(
                preview: CustomerHomeRestaurantPreview(
                  id: '${detail.id}',
                  displayName: detail.name,
                  imageUrl: detail.heroImageUrl,
                ),
                width: width - 36,
                height: heroHeight - MediaQuery.paddingOf(context).top - 64,
              ),
            ),
          if (_hasHeroImage)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
          ),
          if (cartPressed != null)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _CircleIconButton(
                    icon: Icons.shopping_bag_outlined,
                    onPressed: cartPressed,
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: CustomerHomeTokens.primaryMaroon,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            cartCount > 9 ? '9+' : '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: CustomerHomeTokens.primaryMaroon, size: 22),
        ),
      ),
    );
  }
}
