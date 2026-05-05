import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kech_delivery_mobile/src/core/auth/token_persistence.dart';
import 'package:kech_delivery_mobile/src/features/auth/data/auth_repository.dart';

/// Hermetic [AuthRepository] for widget tests (no real network).
AuthRepository createTestAuthRepository() {
  final http.Client client = MockClient((http.Request request) async {
    final String path = request.url.path;
    if (path == '/api/v1/auth/register/customer' && request.method == 'POST') {
      return http.Response(
        jsonEncode(<String, Object?>{'user_id': 7, 'role': 'customer'}),
        201,
      );
    }
    if (path == '/api/v1/auth/token/' && request.method == 'POST') {
      final Map<String, dynamic> body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] == 'wrongwrong') {
        return http.Response(
          jsonEncode(<String, String>{'detail': 'Invalid credentials.'}),
          401,
        );
      }
      return http.Response(
        jsonEncode(<String, Object?>{
          'access': 'test-access',
          'refresh': 'test-refresh',
          'role': 'customer',
          'user_id': 42,
        }),
        200,
      );
    }
    if (path == '/api/v1/auth/me') {
      return http.Response(
        jsonEncode(<String, Object?>{
          'id': 42,
          'phone': '+10000000001',
          'role': 'customer',
          'is_active': true,
          'created_at': '2020-01-01T00:00:00Z',
          'profile': <String, String>{'type': 'customer', 'full_name': 'Test'},
        }),
        200,
      );
    }
    return http.Response('not found', 404);
  });

  return AuthRepository(
    baseUrl: 'http://localhost',
    httpClient: client,
    persistence: MemoryTokenPersistence(),
  );
}
