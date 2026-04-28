import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app/bootstrap.dart';
import 'src/app/kech_delivery_app.dart';
import 'src/core/config/api_base_url.dart';
import 'src/features/auth/data/auth_repository.dart';

Future<void> main() async {
  await bootstrap(() async {
    final AuthRepository authRepository = AuthRepository(baseUrl: ApiBaseUrl.resolve());
    await authRepository.restoreSession();
    runApp(
      Provider<AuthRepository>.value(
        value: authRepository,
        child: const KechDeliveryApp(),
      ),
    );
  });
}
