import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/contracts/customer_home_restaurant_preview.dart';
import '../../../../../shared/contracts/customer_home_service_category.dart';
import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_home_deliver_header.dart';
import '../../../../../shared/widgets/customer_home/customer_home_exclusive_promo_banner.dart';
import '../../../../../shared/widgets/customer_home/customer_home_notifications_button.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_card_skeleton.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_highlight_card.dart';
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

  CustomerHomeServiceCategory _category = CustomerHomeServiceCategory.food;

  List<RestaurantSummary> _topRated = <RestaurantSummary>[];
  List<OrderSummary> _orderNotifications = <OrderSummary>[];
  bool _restaurantsLoading = true;
  bool _orderNotificationsLoading = false;
  String? _restaurantsError;
  Timer? _searchDebounce;
  Timer? _orderNotificationsPoll;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRestaurants();
    _refreshOrderNotifications();
    _orderNotificationsPoll = Timer.periodic(
      const Duration(seconds: 45),
      (_) => _refreshOrderNotifications(),
    );
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final String q = _searchController.text.trim();
      _loadRestaurants(search: q.isEmpty ? null : q);
    });
  }

  Future<void> _loadRestaurants({String? search}) async {
    setState(() {
      _restaurantsLoading = true;
      _restaurantsError = null;
    });
    try {
      final List<RestaurantSummary> data = await context
          .read<RestaurantRepository>()
          .fetchActiveRestaurants(search: search);
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
    final Size size = MediaQuery.sizeOf(context);
    final double topCardWidth =
        (size.width - (CustomerHomeTokens.screenHorizontalPadding * 2) - 8) *
        0.74;
    final double topCardHeight = topCardWidth.clamp(250, 320) * 0.68;

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
                      selected: _category,
                      onCategoryChanged: (CustomerHomeServiceCategory c) =>
                          setState(() => _category = c),
                    ),
                    const SizedBox(height: CustomerHomeTokens.blockSpacing),
                    CustomerHomeExclusivePromoBanner(
                      onClaimPressed: () =>
                          _toast('Promo checkout (coming soon).'),
                    ),
                    const SizedBox(height: CustomerHomeTokens.blockSpacing + 4),
                    CustomerHomeSectionHeader(
                      title: _searchController.text.trim().isEmpty ? 'Top rated' : 'Search results',
                      subtitle: _searchController.text.trim().isEmpty
                          ? 'Fastest delivery in your area'
                          : 'Restaurants matching your search',
                      actionLabel: 'See all',
                      onActionPressed: _openAllRestaurants,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: topCardHeight,
                      child: _restaurantsLoading
                          ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              separatorBuilder: (_, _) => const SizedBox(width: 14),
                              itemBuilder: (_, _) => CustomerHomeRestaurantCardSkeleton(
                                width: topCardWidth.clamp(240, 320),
                                height: topCardHeight,
                              ),
                            )
                          : _restaurantsError != null
                              ? Center(
                                  child: TextButton(
                                    onPressed: _loadRestaurants,
                                    child: Text('Could not load restaurants.\nTap to retry.'),
                                  ),
                                )
                              : _topRated.isEmpty
                                  ? const Center(child: Text('No restaurants yet.'))
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _topRated.length,
                                      separatorBuilder: (BuildContext context, int index) =>
                                          const SizedBox(width: 14),
                                      itemBuilder: (BuildContext _, int index) {
                                        final RestaurantSummary r = _topRated[index];
                                        final CustomerHomeRestaurantPreview preview =
                                            CustomerHomeRestaurantPreview(
                                          id: '${r.id}',
                                          displayName: r.name,
                                          imageUrl: r.heroImageUrl,
                                        );
                                        return CustomerHomeRestaurantHighlightCard(
                                          preview: preview,
                                          width: topCardWidth.clamp(240, 320),
                                          onTap: () => _openRestaurantMenu(r),
                                        );
                                      },
                                    ),
                    ),
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
