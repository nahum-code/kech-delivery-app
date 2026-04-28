import 'package:flutter/material.dart';

import '../../theme/role_selection_tokens.dart';

class RoleSelectionOrDivider extends StatelessWidget {
  const RoleSelectionOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider(color: RoleSelectionTokens.dividerLine, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'OR',
              style: TextStyle(
                color: RoleSelectionTokens.footerMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: RoleSelectionTokens.dividerLine, height: 1)),
        ],
      ),
    );
  }
}
