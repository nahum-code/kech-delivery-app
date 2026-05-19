import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../cart/data/cart_repository.dart';
import '../../../cart/domain/cart_models.dart';
import '../../../cart/presentation/screens/customer_cart_review_screen.dart';
import '../../data/restaurant_repository.dart';
import '../../domain/restaurant_models.dart';
import '../widgets/customer_restaurant_menu_hero.dart';
import '../widgets/customer_restaurant_menu_item_tile.dart';
import 'customer_menu_item_detail_screen.dart';

class CustomerRestaurantMenuScreen extends StatefulWidget {
  const CustomerRestaurantMenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurant,
  });

  final int restaurantId;
  final String restaurantName;
  final RestaurantSummary? restaurant;

  @override
  State<CustomerRestaurantMenuScreen> createState() => _CustomerRestaurantMenuScreenState();
}

class _CustomerRestaurantMenuScreenState extends State<CustomerRestaurantMenuScreen> {
  RestaurantDetail? _detail;
  RestaurantMenu? _menu;
  int _selectedCategoryIndex = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _detail = null;
      _menu = null;
    });
    try {
      final RestaurantRepository repo = context.read<RestaurantRepository>();
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        repo.fetchRestaurantDetail(widget.restaurantId),
        repo.fetchMenu(widget.restaurantId),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = results[0] as RestaurantDetail;
        _menu = results[1] as RestaurantMenu;
        _selectedCategoryIndex = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
        _detail = null;
        _menu = null;
      });
    }
  }

  void _openItem(PublicMenuItem item) {
    final RestaurantDetail? detail = _detail;
    if (detail == null) {
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CustomerMenuItemDetailScreen(
          item: item,
          restaurantId: detail.id,
          restaurantName: detail.name,
        ),
      ),
    );
  }

  Future<void> _addItem(PublicMenuItem item) async {
    final RestaurantDetail? detail = _detail;
    if (detail == null) {
      return;
    }
    await context.read<CartRepository>().addItem(
          restaurantId: detail.id,
          restaurantName: detail.name,
          line: CartLine(
            menuItemId: item.id,
            name: item.name,
            unitPrice: item.price,
            quantity: 1,
            imageUrl: item.imageUrl,
            currency: item.currency,
          ),
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} added to cart')),
    );
  }

  void _openCart() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CustomerCartReviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartRepository cartRepo = context.watch<CartRepository>();
    final int cartCount =
        cartRepo.current?.lines.fold<int>(0, (int s, CartLine l) => s + l.quantity) ?? 0;

    final RestaurantDetail? detail = _detail;
    final RestaurantMenu? menu = _menu;

    return Scaffold(
      backgroundColor: CustomerHomeTokens.canvas,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: CustomerHomeTokens.primaryMaroon),
            )
          : _error != null
              ? _ErrorBody(message: _error ?? 'Something went wrong.', onRetry: _load)
              : detail == null || menu == null
                  ? _ErrorBody(message: 'Could not load this restaurant.', onRetry: _load)
                  : _buildContent(cartCount: cartCount, detail: detail, menu: menu),
      bottomNavigationBar: cartCount > 0 ? _CartBar(count: cartCount, onPressed: _openCart) : null,
    );
  }

  Widget _buildContent({
    required int cartCount,
    required RestaurantDetail detail,
    required RestaurantMenu menu,
  }) {
    final List<PublicMenuCategory> categories =
        menu.categories.where((PublicMenuCategory c) => c.items.isNotEmpty).toList();

    if (categories.isEmpty) {
      return Column(
        children: <Widget>[
          CustomerRestaurantMenuHero(
            detail: detail,
            cartCount: cartCount,
            onBack: () => Navigator.of(context).pop(),
            onCartPressed: _openCart,
          ),
          const Expanded(child: Center(child: Text('No menu items yet.'))),
        ],
      );
    }

    final int categoryIndex = _selectedCategoryIndex.clamp(0, categories.length - 1);
    final PublicMenuCategory activeCategory = categories[categoryIndex];

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: CustomerRestaurantMenuHero(
            detail: detail,
            cartCount: cartCount,
            onBack: () => Navigator.of(context).pop(),
            onCartPressed: _openCart,
          ),
        ),
        SliverToBoxAdapter(
          child: _RestaurantInfoCard(
            detail: detail,
            showTitle: _hasHeroImage(detail),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: CustomerHomeTokens.ink,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                final bool selected = index == categoryIndex;
                return FilterChip(
                  label: Text(categories[index].name),
                  selected: selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : CustomerHomeTokens.labelGray,
                  ),
                  backgroundColor: CustomerHomeTokens.categoryIdleSurface,
                  selectedColor: CustomerHomeTokens.primaryMaroon,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  onSelected: (_) => setState(() => _selectedCategoryIndex = index),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          sliver: SliverList.separated(
            itemCount: activeCategory.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final PublicMenuItem item = activeCategory.items[index];
              return CustomerRestaurantMenuItemTile(
                item: item,
                onTap: () => _openItem(item),
                onAdd: () => _addItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  static bool _hasHeroImage(RestaurantDetail detail) {
    final String? url = detail.heroImageUrl?.trim();
    return url != null && url.isNotEmpty;
  }
}

class _RestaurantInfoCard extends StatelessWidget {
  const _RestaurantInfoCard({required this.detail, this.showTitle = true});

  final RestaurantDetail detail;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CustomerHomeTokens.restaurantCardRadius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (showTitle)
                  Text(
                    detail.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: CustomerHomeTokens.primaryMaroon,
                      height: 1.1,
                    ),
                  ),
                if (detail.description.isNotEmpty) ...<Widget>[
                  if (showTitle) const SizedBox(height: 8),
                  Text(
                    detail.description,
                    style: const TextStyle(
                      color: CustomerHomeTokens.labelGray,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _InfoChip(
                      icon: detail.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      label: detail.isActive ? 'Open now' : 'Closed',
                      emphasized: detail.isActive,
                    ),
                    if (detail.openingHours.isNotEmpty)
                      _InfoChip(icon: Icons.schedule_rounded, label: detail.openingHours),
                    if (detail.menuItemCount > 0)
                      _InfoChip(
                        icon: Icons.restaurant_menu_rounded,
                        label: '${detail.menuItemCount} items',
                      ),
                    if (detail.addressText.isNotEmpty)
                      _InfoChip(icon: Icons.place_outlined, label: detail.addressText),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFF5E8EA) : CustomerHomeTokens.searchFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 14,
              color: emphasized ? CustomerHomeTokens.primaryMaroon : CustomerHomeTokens.labelGray,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: emphasized ? CustomerHomeTokens.primaryMaroon : CustomerHomeTokens.labelGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Material(
        color: CustomerHomeTokens.primaryMaroon,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'View cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: CustomerHomeTokens.primaryMaroon,
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
