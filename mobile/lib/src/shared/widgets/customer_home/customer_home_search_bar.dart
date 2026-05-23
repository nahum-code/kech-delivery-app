import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeSearchBar extends StatelessWidget {
  const CustomerHomeSearchBar({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onSearchTap,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSearchTap;

  void _runSearch() {
    final VoidCallback? tap = onSearchTap;
    if (tap != null) {
      tap();
      return;
    }
    onSubmitted?.call(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerHomeTokens.searchFill,
        borderRadius: BorderRadius.circular(CustomerHomeTokens.searchRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: _runSearch,
              icon: Icon(Icons.search_rounded, color: Colors.grey.shade700, size: 24),
              tooltip: 'Search',
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (String value) {
                  if (onSubmitted != null) {
                    onSubmitted!(value);
                  } else {
                    _runSearch();
                  }
                },
                style: const TextStyle(
                  color: CustomerHomeTokens.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for restaurants or dishes',
                  hintStyle: TextStyle(
                    color: CustomerHomeTokens.mutedCaption,
                    fontWeight: FontWeight.w500,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            TextButton(
              onPressed: _runSearch,
              style: TextButton.styleFrom(
                foregroundColor: CustomerHomeTokens.primaryMaroon,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
