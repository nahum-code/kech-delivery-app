import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/contracts/login_actions.dart';
import '../../../../../shared/contracts/login_credentials.dart';
import '../../../../../shared/contracts/login_result.dart';
import '../../../../../shared/theme/auth_login_tokens.dart';
import '../../../../../shared/theme/auth_login_theme.dart';
import '../../../../../shared/widgets/auth/auth_gradient_login_button.dart';
import '../../../../../shared/widgets/auth/auth_labeled_divider.dart';
import '../../../../../shared/widgets/auth/auth_login_brand_header.dart';
import '../../../../../shared/widgets/auth/auth_login_field_error.dart';
import '../../../../../shared/widgets/auth/auth_login_footer.dart';
import '../../../../../shared/widgets/auth/auth_social_login_button.dart';
import '../validators/login_validators.dart';

/// Shared login surface for customer and driver shells ([LoginActions] is flavor-specific).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.actions});

  final LoginActions actions;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _serverError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() => _serverError = null);
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final LoginResult result = await widget.actions.onSubmit(
        LoginCredentials(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        ),
      );
      if (!mounted) {
        return;
      }
      if (result is LoginFailure) {
        setState(() {
          _serverError = result.message;
          _submitting = false;
        });
        return;
      }
      setState(() => _submitting = false);
    } on Object catch (error, stackTrace) {
      debugPrint('Login submit failed: $error');
      debugPrint('$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _serverError = 'Something went wrong. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuthLoginTheme.light(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AuthLoginTokens.canvas,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuthLoginTokens.horizontalPadding,
                  vertical: 16,
                ),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const AuthLoginBrandHeader(),
                      const SizedBox(height: 32),
                      const Text(
                        'Phone number',
                        style: TextStyle(
                          color: AuthLoginTokens.labelGray,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: LoginValidators.identifier,
                        decoration: const InputDecoration(
                          hintText: '+212 600 000 000',
                          prefixIcon: Icon(
                            Icons.phone_iphone_rounded,
                            color: AuthLoginTokens.hintGray,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: <Widget>[
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: AuthLoginTokens.labelGray,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: AuthLoginTokens.maroon,
                            ),
                            onPressed: widget.actions.onForgotPassword,
                            child: const Text(
                              'Forgot?',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: LoginValidators.password,
                        onFieldSubmitted: (_) => _onSubmit(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(
                            letterSpacing: 2,
                            color: AuthLoginTokens.hintGray,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AuthLoginTokens.hintGray,
                          ),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AuthLoginTokens.hintGray,
                            ),
                          ),
                        ),
                      ),
                      if (_serverError != null) ...<Widget>[
                        AuthLoginFieldError(message: _serverError!),
                      ],
                      const SizedBox(height: 26),
                      AuthGradientLoginButton(
                        loading: _submitting,
                        onPressed: _submitting ? null : _onSubmit,
                      ),
                      const SizedBox(height: 28),
                      const AuthLabeledDivider(label: 'Or continue with'),
                      const SizedBox(height: 18),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AuthSocialLoginButton(
                              label: 'Google',
                              leading: const AuthGoogleGlyph(),
                              onPressed: widget.actions.onGoogle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AuthSocialLoginButton(
                              label: 'Apple',
                              leading: const Icon(
                                Icons.apple,
                                size: 24,
                                color: Color(0xFF424242),
                              ),
                              onPressed: widget.actions.onApple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      AuthLoginFooter(
                        onSignUp: widget.actions.onSignUp,
                        onPrivacyPolicy: widget.actions.onPrivacyPolicy,
                        onTerms: widget.actions.onTerms,
                        onSupport: widget.actions.onSupport,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
