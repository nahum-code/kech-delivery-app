import '../../../../../core/auth/phone_normalizer.dart';

abstract final class CustomerRegistrationValidators {
  static String? fullName(String? raw) {
    final String value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return 'Enter your full name';
    }
    if (value.length < 3) {
      return 'Name is too short';
    }
    return null;
  }

  static String? email(String? raw) {
    final String value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return 'Enter your email';
    }
    final RegExp pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? raw) {
    try {
      PhoneNormalizer.toE164(raw ?? '');
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }

  static String? password(String? raw) {
    final String value = raw ?? '';
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? raw, String password) {
    final String value = raw ?? '';
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
