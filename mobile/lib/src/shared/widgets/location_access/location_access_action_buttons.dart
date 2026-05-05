import 'package:flutter/material.dart';

import '../../theme/customer_location_access_tokens.dart';

class LocationAccessPrimaryActionButton extends StatelessWidget {
  const LocationAccessPrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = FilledButton.styleFrom(
      backgroundColor: CustomerLocationAccessTokens.primaryMaroon,
      disabledBackgroundColor: CustomerLocationAccessTokens.primaryMaroon.withOpacity(0.55),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CustomerLocationAccessTokens.buttonRadius),
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );

    return SizedBox(
      width: double.infinity,
      height: CustomerLocationAccessTokens.buttonHeight,
      child: FilledButton(
        style: style,
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(label),
                  const SizedBox(width: 8),
                  const Icon(Icons.near_me_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

class LocationAccessSecondaryActionButton extends StatelessWidget {
  const LocationAccessSecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: CustomerLocationAccessTokens.buttonHeight,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: CustomerLocationAccessTokens.secondaryButtonFill,
          foregroundColor: CustomerLocationAccessTokens.heroInk,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomerLocationAccessTokens.buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.add_location_alt_outlined, size: 22),
        label: Text(label),
      ),
    );
  }
}
