import '../../../../../core/auth/phone_normalizer.dart';

abstract final class LoginValidators {
  /// E.164 phone (matches Django `normalize_phone` after client-side normalization).
  static String? identifier(String? raw) {
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
}
