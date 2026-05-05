import 'package:flutter/material.dart';

import '../../theme/customer_location_access_tokens.dart';
import 'location_access_action_buttons.dart';
import 'location_access_precision_tile.dart';
import 'location_access_privacy_footer.dart';

class LocationAccessBottomCard extends StatelessWidget {
  const LocationAccessBottomCard({
    super.key,
    required this.onAllowLocation,
    required this.onSelectManually,
    this.allowLocationLoading = false,
  });

  final VoidCallback? onAllowLocation;
  final VoidCallback onSelectManually;
  final bool allowLocationLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CustomerLocationAccessTokens.card,
        borderRadius: BorderRadius.circular(CustomerLocationAccessTokens.cardRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const LocationAccessPrecisionTile(),
            const SizedBox(height: 16),
            LocationAccessPrimaryActionButton(
              label: 'Allow location',
              loading: allowLocationLoading,
              onPressed: onAllowLocation,
            ),
            const SizedBox(height: 10),
            LocationAccessSecondaryActionButton(
              label: 'Select manually',
              onPressed: onSelectManually,
            ),
            const SizedBox(height: 18),
            const LocationAccessPrivacyFooter(),
          ],
        ),
      ),
    );
  }
}
