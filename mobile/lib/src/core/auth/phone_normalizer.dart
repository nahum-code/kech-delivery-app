/// Normalizes user input to E.164 `+<country><digits>` for the Django `normalize_phone` API.
abstract final class PhoneNormalizer {
  /// Returns E.164 phone or throws [FormatException] with a client-safe message.
  static String toE164(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Enter your phone number.');
    }
    if (trimmed.contains('@')) {
      throw const FormatException('Sign in with your phone number (E.164), not email.');
    }

    String digits = trimmed.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.startsWith('00')) {
      digits = '+${digits.substring(2)}';
    }
    if (!digits.startsWith('+')) {
      if (digits.startsWith('0')) {
        digits = '+212${digits.substring(1)}';
      } else if (RegExp(r'^[1-9]\d{6,14}$').hasMatch(digits)) {
        digits = '+$digits';
      } else {
        throw const FormatException('Use international format, e.g. +212600000000');
      }
    }

    final RegExp e164 = RegExp(r'^\+[1-9]\d{7,14}$');
    if (!e164.hasMatch(digits)) {
      throw const FormatException('Invalid phone number length or format.');
    }
    return digits;
  }
}
