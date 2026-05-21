import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/webview/webview_platform_init.dart';

Future<void> bootstrap(FutureOr<void> Function() run) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
        debugPrint('Uncaught platform error: $error');
        debugPrint(stackTrace.toString());
        return true;
      };

      await run();
    },
    (Object error, StackTrace stackTrace) {
      debugPrint('Uncaught zone error: $error');
      debugPrint(stackTrace.toString());
    },
  );
}
