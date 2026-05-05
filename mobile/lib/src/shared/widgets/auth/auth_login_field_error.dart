import 'package:flutter/material.dart';

import '../../theme/auth_login_tokens.dart';

class AuthLoginFieldError extends StatelessWidget {
  const AuthLoginFieldError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AuthLoginTokens.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AuthLoginTokens.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
