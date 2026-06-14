import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_home_deliver_header.dart';
import '../../../../../shared/widgets/customer_home/customer_home_notifications_button.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_card_skeleton.dart';
import '../../../../../shared/widgets/customer_home/customer_home_search_bar.dart';
import '../../../../../shared/widgets/customer_home/customer_home_section_header.dart';
import '../../../../../shared/widgets/customer_home/customer_home_service_category_strip.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../orders/data/order_repository.dart';
import '../../../orders/domain/order_models.dart';
import '../../../orders/presentation/utils/customer_order_navigation.dart';
import '../../../orders/presentation/utils/customer_order_notification_utils.dart';
import '../../../restaurants/data/restaurant_repository.dart';
import '../../../restaurants/domain/restaurant_models.dart';
import '../../../restaurants/presentation/screens/customer_restaurant_menu_screen.dart';
import '../../../restaurants/presentation/screens/customer_restaurants_list_screen.dart';
import '../../../restaurants/presentation/widgets/customer_restaurants_list_tile.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({
    super.key,
    this.deliverAddressLine = 'Home',
    this.embeddedInShell = false,
    this.onViewAllOrders,
  });

  final String deliverAddressLine;
  final bool embeddedInShell;
  final VoidCallback? onViewAllOrders;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Selected filter. Defaults to "Restaurant" (all restaurants). Other values
  /// are menu-category names sourced from the backend.
  String _category = CustomerHomeServiceCategoryStrip.restaurantCategory;
  List<String> _categories = <String>[CustomerHomeServiceCategoryStrip.restaurantCategory];

  List<RestaurantSummary> _topRated = <RestaurantSummary>[];
  List<CatalogMenuItem> _catalogItems = <CatalogMenuItem>[];
  List<OrderSummary> _orderNotifications = <OrderSummary>[];
  bool _restaurantsLoading = true;
  bool _catalogLoading = false;
  bool _orderNotificationsLoading = false;
  String? _restaurantsError;
  String? _catalogError;
  Timer? _searchDebounce;
  Timer? _orderNotificationsPoll;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCategories();
    _loadRestaurants();
    _refreshOrderNotifications();
    _orderNotificationsPoll = Timer.periodic(
      const Duration(seconds: 45),
      (_) => _refreshOrderNotifications(),
    );
  }

  bool get _isRestaurantCategory =>
      _category == CustomerHomeServiceCategoryStrip.restaurantCategory;

  bool get _hasSearch => _searchController.text.trim().isNotEmpty;

  String get _sectionTitle {
    if (!_isRestaurantCategory) return _category;
    return _hasSearch ? 'Search results' : 'Top rated';
  }

  String get _sectionSubtitle {
    if (!_isRestaurantCategory) return 'From all restaurants';
    return _hasSearch
        ? 'Restaurants matching your search'
        : 'Fastest delivery in your area';
  }

  String get _catalogEmptyMessage => 'No $_category items available yet.';

  String get _restaurantsEmptyMessage =>
      _hasSearch ? 'No restaurants match your search.' : 'No restaurants yet.';

  Future<void> _loadCategories() async {
    try {
      final List<String> names =
          await context.read<RestaurantRepository>().fetchMenuCategoryNames();
      if (!mounted) return;
      setState(() {
        _categories = <String>[
          CustomerHomeServiceCategoryStrip.restaurantCategory,
          ...names,
        ];
        // Drop a selection that no longer exists.
        if (!_categories.contains(_category)) {
          _category = CustomerHomeServiceCategoryStrip.restaurantCategory;
        }
      });
    } catch (_) {
      // Non-fatal: the strip still works with just the "Restaurant" filter.
    }
  }

  void _onCategoryChanged(String c) {
    if (c == _category) return;
    setState(() => _category = c);
    if (_isRestaurantCategory) {
      _loadRestaurants();
    } else {
      _loadCategoryItems();
    }
  }

  void _onSearchChanged() {
    // Inline search applies to the restaurant list only.
    if (!_isRestaurantCategory) return;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), _loadRestaurants);
  }

  Future<void> _loadCategoryItems() async {
    final String category = _category;
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    try {
      final List<CatalogMenuItem> data = await context
          .read<RestaurantRepository>()
          .fetchCatalogItems(category: category);
      if (!mounted || category != _category) return;
      setState(() {
        _catalogItems = data;
        _catalogLoading = false;
      });
    } catch (e) {
      if (!mounted || category != _category) return;
      setState(() {
        _catalogError = e.toString();
        _catalogLoading = false;
      });
    }
  }

  void _openItemRestaurant(CatalogMenuItem item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => CustomerRestaurantMenuScreen(
          restaurantId: item.restaurantId,
          restaurantName: item.restaurantName,
        ),
      ),
    );
  }

  Widget _buildRestaurants() {
    if (_restaurantsLoading) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CustomerHomeRestaurantCardSkeleton(width: double.infinity, height: 96),
            ),
        ],
      );
    }
    if (_restaurantsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: TextButton(
            onPressed: _loadRestaurants,
            child: const Text('Could not load restaurants.\nTap to retry.', textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_topRated.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(_restaurantsEmptyMessage)),
      );
    }
    return Column(
      children: <Widget>[
        for (int i = 0; i < _topRated.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomerRestaurantsListTile(
              rank: i + 1,
              restaurant: _topRated[i],
              onTap: () => _openRestaurantMenu(_topRated[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryItems() {
    if (_catalogLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: CustomerHomeTokens.primaryMaroon)),
      );
    }
    if (_catalogError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: TextButton(
            onPressed: _loadCategoryItems,
            child: const Text('Could not load items.\nTap to retry.', textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_catalogItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(_catalogEmptyMessage)),
      );
    }
    return Column(
      children: <Widget>[
        for (final CatalogMenuItem item in _catalogItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CatalogItemCard(item: item, onTap: () => _openItemRestaurant(item)),
          ),
      ],
    );
  }

  Future<void> _loadRestaurants() async {
    final String q = _searchController.text.trim();
    final String? search = q.isEmpty ? null : q;
    final String? category = _isRestaurantCategory ? null : _category;
    setState(() {
      _restaurantsLoading = true;
      _restaurantsError = null;
    });
    try {
      final List<RestaurantSummary> data = await context
          .read<RestaurantRepository>()
          .fetchActiveRestaurants(search: search, category: category);
      if (!mounted) return;
      setState(() {
        _topRated = data;
        _restaurantsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _restaurantsError = e.toString();
        _restaurantsLoading = false;
      });
    }
  }

  void _openRestaurantMenu(RestaurantSummary r) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => CustomerRestaurantMenuScreen(
          restaurantId: r.id,
          restaurantName: r.name,
          restaurant: r,
        ),
      ),
    );
  }

  void _openAllRestaurants() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerRestaurantsListScreen(),
      ),
    );
  }

  void _runSearch() {
    final String q = _searchController.text.trim();
    if (q.isEmpty) {
      _toast('Type a restaurant or dish name to search.');
      return;
    }
    _onSearchSubmitted(q);
  }

  Future<void> _refreshOrderNotifications() async {
    final String? token = context.read<AuthRepository>().currentSession?.accessToken;
    if (token == null) {
      return;
    }
    setState(() => _orderNotificationsLoading = true);
    try {
      final List<OrderSummary> orders =
          await context.read<OrderRepository>().fetchMyOrders(accessToken: token);
      if (!mounted) {
        return;
      }
      setState(() {
        _orderNotifications = orders.where(CustomerOrderNotificationUtils.isNotifiable).toList();
        _orderNotificationsLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _orderNotificationsLoading = false);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _orderNotificationsPoll?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      debugPrint(message);
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchSubmitted(String raw) {
    try {
      final String q = raw.trim();
      if (q.isEmpty) {
        _toast('Type a dish or restaurant to search.');
        return;
      }
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => CustomerRestaurantsListScreen(initialSearch: q),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'customer_home',
          context: ErrorDescription('while handling search submit'),
        ),
      );
      _toast('Search could not start. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeTokens.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CustomerHomeTokens.screenHorizontalPadding,
              ),
              child: CustomerHomeDeliverHeader(
                addressLine: widget.deliverAddressLine,
                trailing: CustomerHomeNotificationsButton(
                  orders: _orderNotifications,
                  loading: _orderNotificationsLoading,
                  onOrderSelected: (OrderSummary order) =>
                      CustomerOrderNavigation.openSummary(context, order),
                  onViewAllOrders: widget.onViewAllOrders,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: CustomerHomeTokens.screenHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CustomerHomeSearchBar(
                      controller: _searchController,
                      onSubmitted: _onSearchSubmitted,
                      onSearchTap: _runSearch,
                    ),
                    const SizedBox(height: CustomerHomeTokens.blockSpacing),
                    CustomerHomeServiceCategoryStrip(
                      categories: _categories,
                      selected: _category,
                      onCategoryChanged: _onCategoryChanged,
                    ),
                    const SizedBox(height: CustomerHomeTokens.blockSpacing + 4),
                    CustomerHomeSectionHeader(
                      title: _sectionTitle,
                      subtitle: _sectionSubtitle,
                      actionLabel: _isRestaurantCategory ? 'See all' : null,
                      onActionPressed: _isRestaurantCategory ? _openAllRestaurants : null,
                    ),
                    const SizedBox(height: 14),
                    if (_isRestaurantCategory)
                      _buildRestaurants()
                    else
                      _buildCategoryItems(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single menu item in the cross-restaurant category browse.
class _CatalogItemCard extends StatelessWidget {
  const _CatalogItemCard({required this.item, required this.onTap});

  final CatalogMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CustomerHomeTokens.searchFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: CustomerHomeTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.storefront_outlined, size: 13, color: CustomerHomeTokens.labelGray),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.restaurantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: CustomerHomeTokens.labelGray, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.price} ${item.currency}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: CustomerHomeTokens.primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: CustomerHomeTokens.labelGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFF0EBE8),
      child: Icon(Icons.fastfood, color: Colors.grey.shade500, size: 22),
    );
  }
}
