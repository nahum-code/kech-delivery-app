import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeSearchBar extends StatelessWidget {
  const CustomerHomeSearchBar({
    super.key,
    required this.controller,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerHomeTokens.searchFill,
        borderRadius: BorderRadius.circular(CustomerHomeTokens.searchRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(
          children: <Widget>[
            Icon(Icons.search_rounded, color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
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
          ],
        ),
      ),
    );
  }
}
