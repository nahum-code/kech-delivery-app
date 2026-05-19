import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/role_selection_bootstrap.dart';
import '../../../../../shared/contracts/customer_home_restaurant_preview.dart';
import '../../../../../shared/contracts/customer_home_service_category.dart';
import '../../../../../shared/contracts/customer_main_tab.dart';
import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_home_deliver_header.dart';
import '../../../../../shared/widgets/customer_home/customer_home_exclusive_promo_banner.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_card_skeleton.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_highlight_card.dart';
import '../../../../../shared/widgets/customer_home/customer_home_search_bar.dart';
import '../../../../../shared/widgets/customer_home/customer_home_section_header.dart';
import '../../../../../shared/widgets/customer_home/customer_home_service_category_strip.dart';
import '../../../shared/widgets/navigation/customer_main_bottom_nav_bar.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../restaurants/data/restaurant_repository.dart';
import '../../../restaurants/domain/restaurant_models.dart';
import '../../../restaurants/presentation/screens/customer_restaurant_menu_screen.dart';
import '../../../orders/presentation/screens/customer_orders_list_screen.dart';
import '../../../restaurants/presentation/screens/customer_restaurants_list_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, this.deliverAddressLine = 'Home'});

  final String deliverAddressLine;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  CustomerHomeServiceCategory _category = CustomerHomeServiceCategory.food;

  List<RestaurantSummary> _topRated = <RestaurantSummary>[];
  bool _restaurantsLoading = true;
  String? _restaurantsError;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRestaurants();
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
        ),
      ),
    );
  }

  void _openAllRestaurants() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext _) => const CustomerRestaurantsListScreen()),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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

  Future<void> _signOut() async {
    try {
      await context.read<AuthRepository>().signOut();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'customer_home',
          context: ErrorDescription('while signing out'),
        ),
      );
      if (mounted) {
        _toast('Could not sign out. Please try again.');
      }
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const RoleSelectionBootstrap(),
      ),
      (Route<dynamic> route) => false,
    );
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

  void _onBottomTab(CustomerMainTab tab) {
    if (tab == CustomerMainTab.home) {
      return;
    }
    if (tab == CustomerMainTab.orders) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const CustomerOrdersListScreen()),
      );
      return;
    }
    _toast('${tab.name} is coming soon.');
  }

  Widget _profileAvatarMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      onSelected: (String value) async {
        if (value == 'sign_out') {
          await _signOut();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'sign_out', child: Text('Sign out')),
      ],
      child: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFFFD4C4),
        child: Text(
          'K',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomerMainBottomNavBar(
          current: CustomerMainTab.home,
          uppercaseLabels: true,
          onTabSelected: _onBottomTab,
        ),
      ),
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
                trailing: _profileAvatarMenu(),
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
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (_, __) => CustomerHomeRestaurantCardSkeleton(
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
