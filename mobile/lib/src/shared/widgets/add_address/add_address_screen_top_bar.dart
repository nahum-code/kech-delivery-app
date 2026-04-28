import 'package:flutter/material.dart';

import '../../theme/customer_add_address_tokens.dart';

class AddAddressScreenTopBar extends StatelessWidget {
  const AddAddressScreenTopBar({
    super.key,
    required this.onBack,
    this.profileInitial = 'K',
  });

  final VoidCallback onBack;
  final String profileInitial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: CustomerAddAddressTokens.ink,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const Expanded(
            child: Text(
              'Add address',
              style: TextStyle(
                color: CustomerAddAddressTokens.primaryMaroon,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: CustomerAddAddressTokens.fieldFill,
            child: Text(
              profileInitial.isNotEmpty ? profileInitial.substring(0, 1).toUpperCase() : '?',
              style: const TextStyle(
                color: CustomerAddAddressTokens.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
