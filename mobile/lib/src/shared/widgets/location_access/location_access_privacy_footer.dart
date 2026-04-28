import 'package:flutter/material.dart';

import '../../theme/customer_location_access_tokens.dart';

class LocationAccessPrivacyFooter extends StatelessWidget {
  const LocationAccessPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      CustomerLocationAccessTokens.privacyFooter,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: CustomerLocationAccessTokens.mutedInk,
        fontSize: 11,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
