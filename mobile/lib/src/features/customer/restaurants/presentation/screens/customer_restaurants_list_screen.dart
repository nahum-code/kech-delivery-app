import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../data/restaurant_repository.dart';
import '../../domain/restaurant_models.dart';
import '../widgets/customer_restaurants_list_tile.dart';
import 'customer_restaurant_menu_screen.dart';

class CustomerRestaurantsListScreen extends StatefulWidget {
  const CustomerRestaurantsListScreen({super.key, this.initialSearch});

  final String? initialSearch;

  @override
  State<CustomerRestaurantsListScreen> createState() => _CustomerRestaurantsListScreenState();
}

class _CustomerRestaurantsListScreenState extends State<CustomerRestaurantsListScreen> {
  final TextEditingController _search = TextEditingController();
  List<RestaurantSummary> _items = <RestaurantSummary>[];
  bool _loading = true;
  String? _error;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final String? initial = widget.initialSearch?.trim();
    if (initial != null && initial.isNotEmpty) {
      _search.text = initial;
    }
    _search.addListener(_onSearchChanged);
    _load(query: initial);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final String q = _search.text.trim();
      _load(query: q.isEmpty ? null : q);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({String? query}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<RestaurantSummary> data =
          await context.read<RestaurantRepository>().fetchActiveRestaurants(search: query);
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openMenu(RestaurantSummary r) {
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

  @override
  Widget build(BuildContext context) {
    final String query = _search.text.trim();

    return Scaffold(
      backgroundColor: CustomerHomeTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerHomeTokens.canvas,
        foregroundColor: CustomerHomeTokens.primaryMaroon,
        elevation: 0,
        title: Text(
          query.isEmpty ? 'All restaurants' : 'Search results',
          style: const TextStyle(fontWeight: FontWeight.w800, color: CustomerHomeTokens.ink),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _search,
                    style: const TextStyle(color: CustomerHomeTokens.ink, fontWeight: FontWeight.w600),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (String v) => _load(query: v.trim().isEmpty ? null : v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search restaurants or dishes',
                      hintStyle: const TextStyle(color: CustomerHomeTokens.labelGray),
                      prefixIcon: const Icon(Icons.search_rounded, color: CustomerHomeTokens.primaryMaroon),
                      filled: true,
                      fillColor: CustomerHomeTokens.searchFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: CustomerHomeTokens.ink.withValues(alpha: 0.08)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: CustomerHomeTokens.ink.withValues(alpha: 0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: CustomerHomeTokens.primaryMaroon, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final String v = _search.text.trim();
                    _load(query: v.isEmpty ? null : v);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: CustomerHomeTokens.primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          if (!_loading && _error == null && _items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_items.length} restaurant${_items.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: CustomerHomeTokens.labelGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Expanded(child: _buildBody(query)),
        ],
      ),
    );
  }

  Widget _buildBody(String query) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: CustomerHomeTokens.primaryMaroon),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.cloud_off_outlined, size: 48, color: CustomerHomeTokens.labelGray),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CustomerHomeTokens.ink, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _load(query: query.isEmpty ? null : query),
                style: FilledButton.styleFrom(backgroundColor: CustomerHomeTokens.primaryMaroon),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            query.isEmpty ? 'No restaurants available.' : 'No restaurants match "$query".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CustomerHomeTokens.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final RestaurantSummary r = _items[index];
        return CustomerRestaurantsListTile(
          rank: index + 1,
          restaurant: r,
          onTap: () => _openMenu(r),
        );
      },
    );
  }
}
