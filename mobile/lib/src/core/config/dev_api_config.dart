/// Local Django URL when running the app on a **physical** phone (same Wi‑Fi as your PC).
///
/// 1. On Windows: `ipconfig` → IPv4 Address on Wi‑Fi (e.g. 192.168.1.42).
/// 2. Set [physicalDeviceHost] below (include `:8000`).
/// 3. Add that IP to `backend/.env` → `ALLOWED_HOSTS=...,192.168.1.42`
/// 4. `flutter run` (no extra flags needed after editing this file).
///
/// Emulator keeps using `10.0.2.2:8000` automatically.
abstract final class DevApiConfig {
  static const String physicalDeviceHost = 'http://192.168.57.10:8000';
}
