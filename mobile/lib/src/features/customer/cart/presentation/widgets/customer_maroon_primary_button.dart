import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';

class CustomerMaroonPrimaryButton extends StatelessWidget {
  const CustomerMaroonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: CustomerCheckoutTokens.primaryMaroon,
          foregroundColor: CustomerCheckoutTokens.onPrimary,
          disabledBackgroundColor: CustomerCheckoutTokens.primaryMaroon.withValues(alpha: 0.5),
          disabledForegroundColor: CustomerCheckoutTokens.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomerCheckoutTokens.buttonRadius)),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: CustomerCheckoutTokens.onPrimary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.6,
                      color: CustomerCheckoutTokens.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: CustomerCheckoutTokens.onPrimary, size: 20),
                ],
              ),
      ),
    );
  }
}
