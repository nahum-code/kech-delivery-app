import '../../../../../core/auth/phone_normalizer.dart';
import '../../../../customer/registration/presentation/validators/customer_registration_validators.dart';

/// Driver registration validators (reuses customer password rules).
abstract final class DriverRegistrationValidators {
  static String? fullName(String? value) => CustomerRegistrationValidators.fullName(value);

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'Email is required';
    }
    if (!v.contains('@') || !v.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    try {
      PhoneNormalizer.toE164(value ?? '');
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }

  static String? password(String? value) => CustomerRegistrationValidators.password(value);

  static String? confirmPassword(String? value, String password) =>
      CustomerRegistrationValidators.confirmPassword(value, password);
}
