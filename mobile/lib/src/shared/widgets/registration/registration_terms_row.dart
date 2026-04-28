import 'package:flutter/material.dart';

import '../../theme/customer_registration_tokens.dart';

class RegistrationTermsRow extends StatelessWidget {
  const RegistrationTermsRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            side: const BorderSide(color: CustomerRegistrationTokens.labelGray, width: 1.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0,
            runSpacing: 4,
            children: <Widget>[
              Text(
                'By checking this box, I agree to the ',
                style: TextStyle(
                  color: CustomerRegistrationTokens.labelGray,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: CustomerRegistrationTokens.primaryMaroon,
                ),
                onPressed: onTermsPressed,
                child: const Text(
                  'Terms',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(
                  color: CustomerRegistrationTokens.labelGray,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: CustomerRegistrationTokens.primaryMaroon,
                ),
                onPressed: onPrivacyPressed,
                child: const Text(
                  'Privacy policy',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              const Text(
                '.',
                style: TextStyle(color: CustomerRegistrationTokens.labelGray, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
