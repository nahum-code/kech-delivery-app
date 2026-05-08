import 'package:flutter/material.dart';

import '../../theme/customer_add_address_tokens.dart';

class AddAddressLabeledTextField extends StatelessWidget {
  const AddAddressLabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.suffix,
    this.keyboardType = TextInputType.streetAddress,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final Widget? suffix;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: CustomerAddAddressTokens.labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: CustomerAddAddressTokens.fieldFill,
            borderRadius: BorderRadius.circular(
              CustomerAddAddressTokens.fieldRadius,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: textInputAction,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      color: CustomerAddAddressTokens.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: CustomerAddAddressTokens.hintGray,
                        fontWeight: FontWeight.w500,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                ?suffix,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
