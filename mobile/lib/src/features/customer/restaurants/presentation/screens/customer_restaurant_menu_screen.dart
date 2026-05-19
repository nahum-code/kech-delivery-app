import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cart/data/cart_repository.dart';
import '../../../cart/domain/cart_models.dart';
import '../../../cart/presentation/screens/customer_checkout_screen.dart';
import '../../data/restaurant_repository.dart';
import '../../domain/restaurant_models.dart';

class CustomerRestaurantMenuScreen extends StatefulWidget {
  const CustomerRestaurantMenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  final int restaurantId;
  final String restaurantName;

  @override
  State<CustomerRestaurantMenuScreen> createState() => _CustomerRestaurantMenuScreenState();
}

class _CustomerRestaurantMenuScreenState extends State<CustomerRestaurantMenuScreen> {
  RestaurantMenu? _menu;
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
    });
    try {
      final RestaurantMenu menu =
          await context.read<RestaurantRepository>().fetchMenu(widget.restaurantId);
      if (!mounted) return;
      setState(() {
        _menu = menu;
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

  @override
  Widget build(BuildContext context) {
    final CartRepository cartRepo = context.watch<CartRepository>();
    final int cartCount = cartRepo.current?.lines.fold<int>(0, (int s, CartLine l) => s + l.quantity) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          if (cartCount > 0)
            TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const CustomerCheckoutScreen()),
              ),
              child: Text('Cart ($cartCount)'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _buildMenu(_menu!),
    );
  }

  Widget _buildMenu(RestaurantMenu menu) {
    if (menu.categories.isEmpty) {
      return const Center(child: Text('No menu items yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: menu.categories.length,
      itemBuilder: (BuildContext context, int index) {
        final PublicMenuCategory category = menu.categories[index];
        if (category.items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ...category.items.map(
              (PublicMenuItem item) => _MenuItemTile(
                item: item,
                onAdd: () async {
                  await context.read<CartRepository>().addItem(
                        restaurantId: widget.restaurantId,
                        restaurantName: widget.restaurantName,
                        line: CartLine(
                          menuItemId: item.id,
                          name: item.name,
                          unitPrice: item.price,
                          quantity: 1,
                          imageUrl: item.imageUrl,
                          currency: item.currency,
                        ),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} added to cart')),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item, required this.onAdd});

  final PublicMenuItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                    : ColoredBox(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.fastfood_rounded, color: Colors.grey.shade500),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  if (item.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${item.price} ${item.currency}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      IconButton.filled(
                        onPressed: onAdd,
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
