import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/auth/driver_onboarding_storage.dart';
import '../../../../../shared/contracts/login_result.dart';
import '../../../../../shared/theme/customer_registration_tokens.dart';
import '../../../../../shared/widgets/registration/registration_solid_primary_button.dart';
import '../../../data/driver_onboarding_repository.dart';
import '../../navigation/driver_otp_navigation.dart';

/// 6-digit phone verification for driver onboarding.
class DriverOtpScreen extends StatefulWidget {
  const DriverOtpScreen({super.key});

  @override
  State<DriverOtpScreen> createState() => _DriverOtpScreenState();
}

class _DriverOtpScreenState extends State<DriverOtpScreen> {
  static const int _codeLength = 6;
  static const int _resendSeconds = 60;

  final List<TextEditingController> _digits =
      List<TextEditingController>.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List<FocusNode>.generate(_codeLength, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendRemaining = 0;
  bool _verifying = false;
  bool _sending = false;
  String _maskedPhone = '';

  @override
  void initState() {
    super.initState();
    _loadPhoneAndSend();
  }

  Future<void> _loadPhoneAndSend() async {
    final DriverOnboardingRepository repo = context.read<DriverOnboardingRepository>();
    final DriverOnboardingSnapshot? snap = repo.currentOnboarding;
    if (snap != null) {
      setState(() => _maskedPhone = _maskPhone(snap.phone));
    }
    await _sendOtp();
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) {
      return phone;
    }
    return '${phone.substring(0, phone.length - 4)}****';
  }

  Future<void> _sendOtp() async {
    if (_resendRemaining > 0 || _sending) {
      return;
    }
    setState(() => _sending = true);
    final DriverOnboardingRepository repo = context.read<DriverOnboardingRepository>();
    final LoginResult result = await repo.sendOtp();
    if (mounted) {
      setState(() => _sending = false);
      if (result is LoginFailure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
        return;
      }
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent.')),
        );
      }
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendRemaining = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendRemaining--;
        if (_resendRemaining <= 0) {
          t.cancel();
        }
      });
    });
  }

  String _collectCode() => _digits.map((TextEditingController c) => c.text).join();

  Future<void> _verify() async {
    final String code = _collectCode();
    if (code.length != _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 6-digit code.')),
      );
      return;
    }
    setState(() => _verifying = true);
    final DriverOnboardingRepository repo = context.read<DriverOnboardingRepository>();
    final LoginResult result = await repo.verifyOtp(code);
    if (!mounted) {
      return;
    }
    setState(() => _verifying = false);
    if (result is LoginFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    DriverOtpNavigation.replaceWithPending(context);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final TextEditingController c in _digits) {
      c.dispose();
    }
    for (final FocusNode n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _digits[index].text = value.substring(value.length - 1);
    }
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color maroon = CustomerRegistrationTokens.primaryMaroon;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: maroon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Security Check',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: maroon),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to your phone\n$_maskedPhone',
                style: const TextStyle(color: CustomerRegistrationTokens.labelGray, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(_codeLength, (int i) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _digits[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: maroon),
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF3E8EB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (String v) => _onDigitChanged(i, v),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                "DIDN'T RECEIVE THE CODE?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  color: CustomerRegistrationTokens.labelGray.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _resendRemaining > 0 || _sending ? null : _sendOtp,
                  child: Text(
                    _resendRemaining > 0
                        ? 'RESEND IN ${_resendRemaining}s'
                        : 'RESEND CODE',
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              RegistrationSolidPrimaryButton(
                label: 'VERIFY IDENTITY',
                loading: _verifying,
                onPressed: _verifying ? null : _verify,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
