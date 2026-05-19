import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/contracts/customer_home_restaurant_preview.dart';
import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../../../shared/widgets/customer_home/customer_home_restaurant_highlight_card.dart';
import '../../data/restaurant_repository.dart';
import '../../domain/restaurant_models.dart';
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

  @override
  void initState() {
    super.initState();
    final String? initial = widget.initialSearch?.trim();
    if (initial != null && initial.isNotEmpty) {
      _search.text = initial;
    }
    _load(query: initial);
  }

  @override
  void dispose() {
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
    final double cardWidth = MediaQuery.sizeOf(context).width - 32;

    return Scaffold(
      backgroundColor: CustomerHomeTokens.canvas,
      appBar: AppBar(title: const Text('Restaurants')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search restaurants',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: CustomerHomeTokens.searchFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onSubmitted: (String v) => _load(query: v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(onPressed: () => _load(), child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _items.isEmpty
                        ? const Center(child: Text('No restaurants available.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) {
                              final RestaurantSummary r = _items[index];
                              final CustomerHomeRestaurantPreview preview =
                                  CustomerHomeRestaurantPreview(
                                id: '${r.id}',
                                displayName: r.name,
                                imageUrl: r.heroImageUrl,
                              );
                              return CustomerHomeRestaurantHighlightCard(
                                preview: preview,
                                width: cardWidth,
                                onTap: () => _openMenu(r),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
