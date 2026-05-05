import 'package:flutter/material.dart';

import '../features/customer/role_selection/navigation/customer_flow_entry.dart';
import '../features/driver/role_selection/navigation/driver_flow_entry.dart';
import '../features/role_selection/presentation/screens/role_selection_screen.dart';
import '../shared/contracts/role_selection_actions.dart';
import '../shared/theme/role_selection_theme.dart';

/// App shell: light theme + shared role UI + flavor-specific navigation hooks.
class RoleSelectionBootstrap extends StatelessWidget {
  const RoleSelectionBootstrap({super.key});

  void _showTermsPlaceholder(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Terms of service (placeholder). Replace with in-app WebView or url_launcher.',
            style: Theme.of(sheetContext).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  void _showUtilityTodo(BuildContext context, String label) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('$label (no ScaffoldMessenger)');
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text('$label (TODO)')));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RoleSelectionTheme.light,
      child: Builder(
        builder: (BuildContext scopedContext) {
          return RoleSelectionScreen(
            actions: RoleSelectionActions(
              onContinueAsCustomer: () => CustomerFlowEntry.openFromRoleSelection(scopedContext),
              onContinueAsDriver: () => DriverFlowEntry.openFromRoleSelection(scopedContext),
              onTermsOfService: () => _showTermsPlaceholder(scopedContext),
              onLanguage: () => _showUtilityTodo(scopedContext, 'Language'),
              onAccount: () => _showUtilityTodo(scopedContext, 'Account'),
              onTrust: () => _showUtilityTodo(scopedContext, 'Trust & safety'),
            ),
          );
        },
      ),
    );
  }
}
