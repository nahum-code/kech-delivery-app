import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/contracts/login_result.dart';
import '../../../../../shared/theme/customer_registration_tokens.dart';
import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../../../shared/widgets/registration/registration_labeled_text_field.dart';
import '../../../../../shared/widgets/registration/registration_solid_primary_button.dart';
import '../../../../driver/data/driver_onboarding_repository.dart';
import '../../navigation/driver_registration_navigation.dart';
import '../validators/driver_registration_validators.dart';

/// Driver partner registration (does not auto-login; pending approval workflow).
class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  String _vehicleType = 'sedan';
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final DriverOnboardingRepository repo = context.read<DriverOnboardingRepository>();
      final LoginResult result = await repo.registerDriver(
        fullName: _fullName.text,
        email: _email.text,
        phoneRaw: _phone.text,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
        vehicleType: _vehicleType,
      );
      if (!mounted) {
        return;
      }
      if (result is LoginFailure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
        return;
      }
      DriverRegistrationNavigation.openDocuments(context);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: DriverAppTokens.screenBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: CustomerRegistrationTokens.primaryMaroon,
                    ),
                    const Spacer(),
                    Text(
                      'KECH',
                      style: TextStyle(
                        color: CustomerRegistrationTokens.primaryMaroon.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'KECH DELIVERY',
                      style: TextStyle(
                        color: CustomerRegistrationTokens.primaryMaroon,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start your journey.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2A1018),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Become a partner in precision delivery.',
                      style: TextStyle(color: CustomerRegistrationTokens.labelGray, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        RegistrationLabeledTextField(
                          label: 'FULL NAME',
                          hint: 'Marcus V.',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _fullName,
                          validator: DriverRegistrationValidators.fullName,
                        ),
                        const SizedBox(height: 16),
                        RegistrationLabeledTextField(
                          label: 'EMAIL ADDRESS',
                          hint: 'marcus.v@kech.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: DriverRegistrationValidators.email,
                        ),
                        const SizedBox(height: 16),
                        RegistrationLabeledTextField(
                          label: 'PHONE NUMBER',
                          hint: '+212 600 000 000',
                          prefixIcon: Icons.phone_android_rounded,
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          validator: DriverRegistrationValidators.phone,
                        ),
                        const SizedBox(height: 16),
                        RegistrationLabeledTextField(
                          label: 'PASSWORD',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _password,
                          obscureText: _obscurePassword,
                          validator: DriverRegistrationValidators.password,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        RegistrationLabeledTextField(
                          label: 'CONFIRM PASSWORD',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          controller: _confirmPassword,
                          obscureText: _obscureConfirm,
                          validator: (String? v) =>
                              DriverRegistrationValidators.confirmPassword(v, _password.text),
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'VEHICLE TYPE',
                            style: TextStyle(
                              color: CustomerRegistrationTokens.primaryMaroon,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _VehicleChip(
                                label: 'SEDAN',
                                icon: Icons.directions_car_filled_rounded,
                                selected: _vehicleType == 'sedan',
                                onTap: () => setState(() => _vehicleType = 'sedan'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _VehicleChip(
                                label: 'MOTORBIKE',
                                icon: Icons.two_wheeler_rounded,
                                selected: _vehicleType == 'motorbike',
                                onTap: () => setState(() => _vehicleType = 'motorbike'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        RegistrationSolidPrimaryButton(
                          label: 'CREATE ACCOUNT',
                          loading: _submitting,
                          onPressed: _submitting ? null : _onSubmit,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color maroon = CustomerRegistrationTokens.primaryMaroon;
    return Material(
      color: selected ? maroon : const Color(0xFFF3E8EB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: <Widget>[
              Icon(icon, color: selected ? Colors.white : maroon),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : maroon,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
