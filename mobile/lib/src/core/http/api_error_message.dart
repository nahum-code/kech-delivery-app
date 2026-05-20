/// Parses Django/DRF error bodies into a short user-facing message.
String parseApiErrorMessage(dynamic body, String fallback) {
  if (body is! Map<String, dynamic>) {
    return fallback;
  }

  final dynamic detail = body['detail'];
  if (detail is String && detail.trim().isNotEmpty) {
    return detail.trim();
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

String _formatFieldError(String field, dynamic value) {
  if (value is List && value.isNotEmpty) {
    return '$field: ${value.first}';
  }
  if (value is String && value.isNotEmpty) {
    return '$field: $value';
  }
  return field;
}
