import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_restaurant_preview_image.dart';
import '../../domain/restaurant_models.dart';

/// Accessible restaurant row for the "See all" list (theme + non-color-only cues).
class CustomerRestaurantsListTile extends StatelessWidget {
  const CustomerRestaurantsListTile({
    super.key,
    required this.rank,
    required this.restaurant,
    required this.onTap,
  });

  /// 1-based position shown to the user.
  final int rank;
  final RestaurantSummary restaurant;
  final VoidCallback onTap;

  static const double thumbSize = 88;

  @override
  Widget build(BuildContext context) {
    final String rankLabel = '#$rank';
    final String statusLabel = restaurant.isOpen ? 'Open now' : 'Closed';
    final IconData statusIcon = restaurant.isOpen ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Semantics(
      button: true,
      label: '$rankLabel ${restaurant.name}. $statusLabel.',
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: CustomerHomeTokens.primaryMaroon.withValues(alpha: 0.12)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RankBadge(rank: rank, rankLabel: rankLabel),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(height: 1.25),
                          children: <TextSpan>[
                            TextSpan(
                              text: '$rankLabel · ',
                              style: const TextStyle(
                                color: CustomerHomeTokens.primaryMaroon,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: restaurant.name,
                              style: const TextStyle(
                                color: CustomerHomeTokens.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (restaurant.description.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          restaurant.description.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomerHomeTokens.labelGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          _StatusChip(
                            icon: statusIcon,
                            label: statusLabel,
                            emphasized: restaurant.isOpen,
                          ),
                          _StatusChip(
                            icon: Icons.restaurant_menu_outlined,
                            label: '${restaurant.menuItemCount} items',
                            emphasized: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: thumbSize,
                    height: thumbSize,
                    child: CustomerRestaurantPreviewImage(
                      imageUrl: restaurant.heroImageUrl,
                      placeholderIconSize: 32,
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

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.rankLabel});

  final int rank;
  final String rankLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CustomerHomeTokens.primaryMaroon,
            shape: BoxShape.circle,
            border: Border.all(color: CustomerHomeTokens.ink, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rankLabel,
          style: const TextStyle(
            color: CustomerHomeTokens.ink,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.emphasized,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final Color fg = emphasized ? CustomerHomeTokens.ink : CustomerHomeTokens.labelGray;
    final Color bg = emphasized
        ? CustomerHomeTokens.primaryMaroon.withValues(alpha: 0.08)
        : CustomerHomeTokens.searchFill;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CustomerHomeTokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
