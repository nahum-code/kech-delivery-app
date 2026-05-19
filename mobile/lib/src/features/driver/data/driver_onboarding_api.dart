import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Driver onboarding REST client (registration token auth, multipart uploads).
final class DriverOnboardingApi {
  DriverOnboardingApi({
    required String baseUrl,
    http.Client? httpClient,
  })  : _base = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _client = httpClient ?? http.Client();

  final String _base;
  final http.Client _client;

  static const String registrationTokenHeader = 'X-Registration-Token';

  Uri _u(String path) => Uri.parse('$_base$path');

  Map<String, String> _tokenHeaders(String registrationToken) => <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        registrationTokenHeader: registrationToken,
      };

  Future<http.Response> registerDriver({
    required String phone,
    required String password,
    required String name,
    required String email,
    required String vehicleType,
  }) {
    return _client.post(
      _u('/api/v1/auth/register/driver'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{
        'phone': phone,
        'password': password,
        'name': name,
        'email': email,
        'vehicle_type': vehicleType,
      }),
    );
  }

  Future<http.Response> fetchOnboardingStatus({required String registrationToken}) {
    return _client.get(
      _u('/api/v1/drivers/onboarding/status/'),
      headers: _tokenHeaders(registrationToken),
    );
  }

  Future<http.Response> fetchDriverStatus({required String accessToken}) {
    return _client.get(
      _u('/api/v1/drivers/me/status/'),
      headers: <String, String>{
        ..._jsonHeaders,
        HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      },
    );
  }

  Future<http.StreamedResponse> uploadDocument({
    required String registrationToken,
    required String documentType,
    required String filePath,
    required String filename,
    String? contentType,
  }) async {
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      _u('/api/v1/drivers/onboarding/documents/'),
    );
    request.headers.addAll(_tokenHeaders(registrationToken));
    request.fields['document_type'] = documentType;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filename,
        contentType: contentType != null ? MediaType.parse(contentType) : null,
      ),
    );
    return _client.send(request);
  }

  Future<http.Response> sendOtp({
    required String registrationToken,
    required String phone,
  }) {
    return _client.post(
      _u('/api/v1/auth/otp/driver/send/'),
      headers: <String, String>{
        ..._jsonHeaders,
        registrationTokenHeader: registrationToken,
      },
      body: jsonEncode(<String, String>{'phone': phone}),
    );
  }

  Future<http.Response> verifyOtp({
    required String registrationToken,
    required String phone,
    required String code,
  }) {
    return _client.post(
      _u('/api/v1/auth/otp/driver/verify/'),
      headers: <String, String>{
        ..._jsonHeaders,
        registrationTokenHeader: registrationToken,
      },
      body: jsonEncode(<String, String>{'phone': phone, 'code': code}),
    );
  }

  static const Map<String, String> _jsonHeaders = <String, String>{
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };
}
