import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_profile_tokens.dart';
import '../../../../auth/data/auth_repository.dart';

/// Update recovery email used for forgot-password verification.
class CustomerUpdateEmailScreen extends StatefulWidget {
  const CustomerUpdateEmailScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<CustomerUpdateEmailScreen> createState() => _CustomerUpdateEmailScreenState();
}

class _CustomerUpdateEmailScreenState extends State<CustomerUpdateEmailScreen> {
  late final TextEditingController _emailController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final String? err = await context.read<AuthRepository>().updateCustomerProfile(email: email);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerProfileTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerProfileTokens.canvas,
        elevation: 0,
        foregroundColor: CustomerProfileTokens.primaryMaroon,
        title: const Text(
          'Recovery email',
          style: TextStyle(fontWeight: FontWeight.w800, color: CustomerProfileTokens.titleInk),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(CustomerProfileTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CustomerProfileTokens.eliteBadgeFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8C4CC)),
                ),
                child: const Text(
                  'This email is used to verify your identity when you reset your password. '
                  'Keep it up to date so you can recover your account.',
                  style: TextStyle(
                    color: CustomerProfileTokens.bodyMuted,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  color: CustomerProfileTokens.subtitleGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CustomerProfileTokens.titleInk,
                ),
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8D4D8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8D4D8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: CustomerProfileTokens.primaryMaroon, width: 1.5),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: CustomerProfileTokens.primaryMaroon,
                    foregroundColor: CustomerProfileTokens.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save email', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
