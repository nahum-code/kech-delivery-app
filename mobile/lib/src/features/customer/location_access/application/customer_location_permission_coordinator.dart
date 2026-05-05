import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum CustomerLocationWhenInUseOutcome {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  serviceError,
}

abstract final class CustomerLocationPermissionCoordinator {
  static Future<CustomerLocationWhenInUseOutcome> requestWhenInUse() async {
    try {
      final PermissionStatus status = await Permission.locationWhenInUse.request();
      return _mapStatus(status);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'customer_location_access',
          context: ErrorDescription('while requesting locationWhenInUse permission'),
        ),
      );
      return CustomerLocationWhenInUseOutcome.serviceError;
    }
  }

  static Future<bool> openSystemSettings() => openAppSettings();

  static CustomerLocationWhenInUseOutcome _mapStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return CustomerLocationWhenInUseOutcome.granted;
      case PermissionStatus.denied:
        return CustomerLocationWhenInUseOutcome.denied;
      case PermissionStatus.permanentlyDenied:
        return CustomerLocationWhenInUseOutcome.permanentlyDenied;
      case PermissionStatus.restricted:
        return CustomerLocationWhenInUseOutcome.restricted;
      case PermissionStatus.provisional:
        return CustomerLocationWhenInUseOutcome.granted;
    }
  }
}
