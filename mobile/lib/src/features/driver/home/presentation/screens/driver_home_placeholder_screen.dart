import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../../../app/role_selection_bootstrap.dart';

/// Temporary shell after driver login (replace with real driver home).
class DriverHomePlaceholderScreen extends StatelessWidget {
  const DriverHomePlaceholderScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthRepository>().signOut();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (BuildContext _) => const RoleSelectionBootstrap()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kech Delivery — Driver')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Driver home (TODO)'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _signOut(context),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
