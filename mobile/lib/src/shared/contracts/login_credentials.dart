import 'package:flutter/foundation.dart';

@immutable
class LoginCredentials {
  const LoginCredentials({
    required this.identifier,
    required this.password,
  });

  final String identifier;
  final String password;
}
