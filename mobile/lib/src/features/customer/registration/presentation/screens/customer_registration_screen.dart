import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/contracts/login_result.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/customer_registration_tokens.dart';
import '../../../../../shared/widgets/registration/registration_brand_location_row.dart';
import '../../../../../shared/widgets/registration/registration_card_shell.dart';
import '../../../../../shared/widgets/registration/registration_labeled_text_field.dart';
import '../../../../../shared/widgets/registration/registration_solid_primary_button.dart';
import '../../../../../shared/widgets/registration/registration_terms_row.dart';
import '../validators/customer_registration_validators.dart';

/// Customer-only registration surface (reuses shared registration widgets).
class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() => _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState extends State<CustomerRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _acceptedTerms = false;
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

  Future<void> _onRegister() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    if (!_acceptedTerms) {
      final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Please accept the Terms and Privacy policy to continue.')),
        );
      }
      return;
    }

    setState(() => _submitting = true);
    try {
      final AuthRepository auth = context.read<AuthRepository>();
      final LoginResult result = await auth.registerCustomerAndSignIn(
        fullName: _fullName.text,
        email: _email.text,
        phoneRaw: _phone.text,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
      );
      if (!mounted) {
        return;
      }
      if (result is LoginFailure) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        return;
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Welcome! Your account is ready.')),
      );
      Navigator.of(context).pop();
    } on Object catch (error, stackTrace) {
      debugPrint('Registration failed: $error');
      debugPrint('$stackTrace');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _snack(String message) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint(message);
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final int year = DateTime.now().year;

    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return CustomerRegistrationTokens.primaryMaroon;
            }
            return Colors.white;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: CustomerRegistrationTokens.canvas,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: CustomerRegistrationTokens.canvas,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const RegistrationBrandLocationRow(),
                Expanded(
                  child: RegistrationCardShell(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Text(
                              'Create account',
                              style: TextStyle(
                                color: CustomerRegistrationTokens.primaryMaroon,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Sign up to start your first delivery journey.',
                              style: TextStyle(
                                color: CustomerRegistrationTokens.labelGray,
                                fontSize: 15,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 26),
                            RegistrationLabeledTextField(
                              label: 'Full name',
                              hint: 'Yassine El Amrani',
                              prefixIcon: Icons.person_outline_rounded,
                              controller: _fullName,
                              validator: CustomerRegistrationValidators.fullName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 18),
                            RegistrationLabeledTextField(
                              label: 'Email',
                              hint: 'you@example.com',
                              prefixIcon: Icons.mail_outline_rounded,
                              controller: _email,
                              validator: CustomerRegistrationValidators.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 18),
                            RegistrationLabeledTextField(
                              label: 'Phone number',
                              hint: '+212 600 000 000',
                              prefixIcon: Icons.smartphone_rounded,
                              controller: _phone,
                              validator: CustomerRegistrationValidators.phone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 18),
                            RegistrationLabeledTextField(
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              controller: _password,
                              validator: CustomerRegistrationValidators.password,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              suffix: IconButton(
                                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: CustomerRegistrationTokens.labelGray,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            RegistrationLabeledTextField(
                              label: 'Confirm password',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              controller: _confirmPassword,
                              validator: (String? v) =>
                                  CustomerRegistrationValidators.confirmPassword(v, _password.text),
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onRegister(),
                              suffix: IconButton(
                                tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: CustomerRegistrationTokens.labelGray,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            RegistrationTermsRow(
                              value: _acceptedTerms,
                              onChanged: (bool? v) => setState(() => _acceptedTerms = v ?? false),
                              onTermsPressed: () => _snack('Terms (TODO)'),
                              onPrivacyPressed: () => _snack('Privacy policy (TODO)'),
                            ),
                            const SizedBox(height: 22),
                            RegistrationSolidPrimaryButton(
                              label: 'Register',
                              loading: _submitting,
                              onPressed: _submitting ? null : _onRegister,
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: <Widget>[
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: CustomerRegistrationTokens.labelGray,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: CustomerRegistrationTokens.primaryMaroon,
                                  ),
                                  onPressed: () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text(
                                    'Log in',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              '© $year KECH DELIVERY SERVICE',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: CustomerRegistrationTokens.footerMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
