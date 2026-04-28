import 'package:flutter/material.dart';

import '../../theme/role_selection_tokens.dart';

class RoleSelectionCustomerTile extends StatelessWidget {
  const RoleSelectionCustomerTile({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RoleSelectionTokens.customerCard,
      borderRadius: BorderRadius.circular(RoleSelectionTokens.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: RoleSelectionTokens.dividerLine),
                ),
                child: const Icon(
                  Icons.shopping_basket_outlined,
                  color: RoleSelectionTokens.primaryBurgundy,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Continue as customer',
                      style: TextStyle(
                        color: RoleSelectionTokens.deliveryGray,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Order food, groceries & more',
                      style: TextStyle(
                        color: RoleSelectionTokens.subheadGray,
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: RoleSelectionTokens.deliveryGray,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
