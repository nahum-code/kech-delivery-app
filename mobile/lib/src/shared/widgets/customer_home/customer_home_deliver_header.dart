import 'package:flutter/material.dart';

import '../../theme/customer_home_tokens.dart';

class CustomerHomeDeliverHeader extends StatelessWidget {
  const CustomerHomeDeliverHeader({
    super.key,
    required this.addressLine,
    this.profileInitial = 'K',
    this.trailing,
    this.onAvatarPressed,
  });

  final String addressLine;
  final String profileInitial;
  final Widget? trailing;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: CustomerHomeTokens.searchFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.place_rounded, color: CustomerHomeTokens.primaryMaroon, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Deliver to',
                  style: TextStyle(
                    color: CustomerHomeTokens.labelGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  addressLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerHomeTokens.primaryMaroon,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAvatarPressed,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFFFD4C4),
                    child: Text(
                      profileInitial.isNotEmpty ? profileInitial.substring(0, 1).toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
