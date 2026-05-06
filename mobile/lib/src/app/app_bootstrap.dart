import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/customer/home/presentation/screens/customer_home_screen.dart';
import '../features/driver/home/presentation/screens/driver_home_placeholder_screen.dart';
import '../shared/widgets/loading/splash_loading_indicator.dart';
import 'role_selection_bootstrap.dart';

/// Destination route after app initialization completes.
sealed class _AppInitDestination {
  const _AppInitDestination();
}

/// User is unauthenticated, show role selection screen.
final class _DestinationRoleSelection extends _AppInitDestination {
  const _DestinationRoleSelection();
}

/// User is authenticated as customer, show home.
final class _DestinationCustomerHome extends _AppInitDestination {
  const _DestinationCustomerHome();
}

/// User is authenticated as driver, show home.
final class _DestinationDriverHome extends _AppInitDestination {
  const _DestinationDriverHome();
}

/// Production app initialization: auth state check + splash display, then route.
///
/// This widget determines where to navigate BEFORE rendering any screen,
/// preventing double-UI rendering issues.
///
/// Flow:
/// 1. Checks if user has valid session (restoreSession already called in main)
/// 2. Shows splash for minimum 2 seconds (branded experience)
/// 3. Once complete, renders destination screen (role selection or home)
/// 4. No Navigator.pushReplacement hacks—just widget tree updates
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<_AppInitDestination> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  /// Initializes app: determines auth state + enforces minimum splash duration.
  ///
  /// Returns destination widget to render based on:
  /// - No session → role selection (unauthenticated)
  /// - Customer role → customer home (authenticated)
  /// - Driver role → driver home (authenticated)
  /// - Other → role selection (safe fallback)
  Future<_AppInitDestination> _initializeApp() async {
    // Ensure splash is visible for minimum 2 seconds (good UX practice)
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      // If widget was disposed during delay, still return valid destination
      return const _DestinationRoleSelection();
    }

    final AuthRepository authRepository = context.read<AuthRepository>();
    final session = authRepository.currentSession;

    if (session == null) {
      return const _DestinationRoleSelection();
    }

    // Route based on role
    return switch (session.role) {
      'customer' => const _DestinationCustomerHome(),
      'driver' => const _DestinationDriverHome(),
      _ => const _DestinationRoleSelection(), // unknown role fallback
    };
  }

  /// Builds destination widget without navigation—purely widget tree.
  Widget _buildDestination(_AppInitDestination destination) {
    return switch (destination) {
      _DestinationRoleSelection() => const RoleSelectionBootstrap(),
      _DestinationCustomerHome() => const CustomerHomeScreen(),
      _DestinationDriverHome() => const DriverHomePlaceholderScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppInitDestination>(
      future: _initializationFuture,
      builder:
          (BuildContext context, AsyncSnapshot<_AppInitDestination> snapshot) {
            // While initializing or if error, show splash screen
            if (!snapshot.hasData) {
              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.grey[50]!],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        SplashLoadingIndicator(
                          title: 'Kech Delivery',
                          subtitle: 'Initializing your app...',
                          ringSize: 112,
                          ringStrokeWidth: 11,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Initialization complete: render destination
            return _buildDestination(snapshot.data!);
          },
    );
  }
}
