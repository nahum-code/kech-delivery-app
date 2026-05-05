import 'package:flutter/foundation.dart';

@immutable
sealed class LoginResult {
  const LoginResult();
}

@immutable
class LoginSuccess extends LoginResult {
  const LoginSuccess();
}

@immutable
class LoginFailure extends LoginResult {
  const LoginFailure(this.message);

  final String message;
}
