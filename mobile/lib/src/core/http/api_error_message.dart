import 'dart:convert';
import 'dart:io';

/// API failure with a user-facing message (no `Exception:` prefix in UI).
final class AppApiException implements Exception {
  const AppApiException(this.message, {this.statusCode, this.sessionExpired = false});

  final String message;
  final int? statusCode;
  final bool sessionExpired;

  @override
  String toString() => message;
}

/// Parses Django/DRF error bodies into a short user-facing message.
String parseApiErrorMessage(dynamic body, String fallback) {
  if (body is! Map<String, dynamic>) {
    return fallback;
  }

  final dynamic detail = body['detail'];
  if (detail is String && detail.trim().isNotEmpty) {
    return _humanizeAuthDetail(detail.trim());
  }
  if (detail is Map) {
    final List<String> parts = <String>[];
    for (final MapEntry<dynamic, dynamic> entry in detail.entries) {
      parts.add(_formatFieldError('${entry.key}', entry.value));
    }
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
  }

  final dynamic message = body['message'];
  if (message is String && message.trim().isNotEmpty) {
    return message.trim();
  }
  if (message is Map) {
    final List<String> parts = <String>[];
    for (final MapEntry<dynamic, dynamic> entry in message.entries) {
      parts.add(_formatFieldError('${entry.key}', entry.value));
    }
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
  }

  return fallback;
}

/// Maps thrown errors (including JWT failures) to readable copy for SnackBars / banners.
String userMessageFrom(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is AppApiException) {
    return error.message;
  }

  final String raw = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  if (raw.isEmpty) {
    return fallback;
  }

  if (_isSessionExpiredText(raw)) {
    return 'Your session expired. Please sign in again.';
  }

  final String lower = raw.toLowerCase();
  if (lower.contains('socketexception') || lower.contains('failed host lookup')) {
    return 'Cannot reach the server. Check your connection and API address in dev settings.';
  }
  if (lower.contains('connection refused') || lower.contains('connection timed out')) {
    return 'Cannot connect to the server. Ensure the backend is running.';
  }

  return raw;
}

bool isSessionExpiredError(Object error) {
  if (error is AppApiException) {
    return error.sessionExpired;
  }
  return _isSessionExpiredText(error.toString());
}

bool _isSessionExpiredText(String text) {
  final String lower = text.toLowerCase();
  return lower.contains('token not valid') ||
      lower.contains('token_not_valid') ||
      lower.contains('given token not valid') ||
      lower.contains('token is invalid') ||
      lower.contains('authentication credentials were not provided') ||
      lower.contains('session expired');
}

String _humanizeAuthDetail(String detail) {
  if (_isSessionExpiredText(detail)) {
    return 'Your session expired. Please sign in again.';
  }
  return detail;
}

String _formatFieldError(String field, dynamic value) {
  if (value is List && value.isNotEmpty) {
    return '$field: ${value.first}';
  }
  if (value is String && value.isNotEmpty) {
    return '$field: $value';
  }
  return field;
}

AppApiException apiExceptionFromResponse({
  required int statusCode,
  required String body,
  required String fallback,
}) {
  dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } catch (_) {
    decoded = null;
  }

  final String message = parseApiErrorMessage(decoded, fallback);
  final bool sessionExpired = statusCode == 401 || _isSessionExpiredText(message);

  return AppApiException(
    sessionExpired ? 'Your session expired. Please sign in again.' : message,
    statusCode: statusCode,
    sessionExpired: sessionExpired,
  );
}

String networkErrorHint() {
  if (Platform.isAndroid || Platform.isIOS) {
    return 'Cannot reach the server. Check Wi‑Fi and your API URL in dev settings.';
  }
  return 'Cannot reach the server. Ensure the backend is running.';
}
