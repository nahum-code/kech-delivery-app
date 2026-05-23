import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/data/auth_repository.dart';

/// Confirms and deletes (deactivates) the signed-in customer or driver account.
class ProfileDeleteAccountButton extends StatefulWidget {
  const ProfileDeleteAccountButton({
    super.key,
    required this.foregroundColor,
    required this.onDeleted,
  });

  final Color foregroundColor;
  final VoidCallback onDeleted;

  @override
  State<ProfileDeleteAccountButton> createState() => _ProfileDeleteAccountButtonState();
}

class _ProfileDeleteAccountButtonState extends State<ProfileDeleteAccountButton> {
  bool _busy = false;

  Future<void> _confirmAndDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'Your account will be permanently deactivated. You will not be able to sign in again. '
            'Active orders must be finished or cancelled first.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Delete account'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busy = true);
    final String? error = await context.read<AuthRepository>().deleteAccount();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: _busy ? null : () => _confirmAndDelete(),
        style: TextButton.styleFrom(
          foregroundColor: widget.foregroundColor,
        ),
        child: _busy
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.foregroundColor,
                ),
              )
            : const Text(
                'Delete account',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
      ),
    );
  }
}
