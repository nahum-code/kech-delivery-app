import 'package:flutter/material.dart';

import '../../theme/customer_registration_tokens.dart';

/// Uppercase label + filled rounded field (shared across customer registration flows).
class RegistrationLabeledTextField extends StatelessWidget {
  const RegistrationLabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.suffix,
  });

  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: CustomerRegistrationTokens.labelGray,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(
            color: CustomerRegistrationTokens.ink,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: CustomerRegistrationTokens.hintGray, fontSize: 15),
            filled: true,
            fillColor: CustomerRegistrationTokens.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomerRegistrationTokens.fieldRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomerRegistrationTokens.fieldRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomerRegistrationTokens.fieldRadius),
              borderSide: const BorderSide(color: CustomerRegistrationTokens.primaryMaroon, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomerRegistrationTokens.fieldRadius),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            prefixIcon: Icon(prefixIcon, color: CustomerRegistrationTokens.labelGray, size: 22),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
