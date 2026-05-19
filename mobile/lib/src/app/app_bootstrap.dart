import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/auth_repository.dart';
import '../core/auth/auth_session_snapshot.dart';
import '../features/customer/shell/presentation/screens/customer_shell_screen.dart';
import '../features/driver/data/driver_onboarding_repository.dart';
import '../features/driver/shell/presentation/screens/driver_shell_screen.dart';
import '../features/driver/pending/presentation/screens/driver_pending_screen.dart';
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

/// Driver registered but awaiting approval (onboarding token, no JWT).
final class _DestinationDriverPending extends _AppInitDestination {
  const _DestinationDriverPending();
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

  /// Retry initialization if a previous attempt failed.
  void _retryInitialization() {
    if (!mounted) return;
    setState(() {
      _initializationFuture = _initializeApp();
    });
  }

  /// Initializes app: determines auth state + enforces minimum splash duration.
  ///
  /// Returns destination widget to render based on:
  /// - No session → role selection (unauthenticated)
  /// - Customer role → customer home (authenticated)
  /// - Driver role → driver home (authenticated)
  /// - Other → role selection (safe fallback)
  Future<_AppInitDestination> _initializeApp() async {
    final AuthRepository authRepository = context.read<AuthRepository>();

    // Ensure splash is visible for minimum 2 seconds (good UX practice)
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      // If widget was disposed during delay, still return valid destination
      return const _DestinationRoleSelection();
    }

    final session = authRepository.currentSession;

    if (session == null) {
      final DriverOnboardingRepository onboarding = context.read<DriverOnboardingRepository>();
      if (onboarding.currentOnboarding != null) {
        return const _DestinationDriverPending();
      }
      return const _DestinationRoleSelection();
    }

    // Route based on typed role enum (safer than string literals)
    return switch (session.roleEnum) {
      Role.customer => const _DestinationCustomerHome(),
      Role.driver => const _DestinationDriverHome(),
      _ => const _DestinationRoleSelection(), // unknown role fallback
    };
  }
  /// Builds destination widget without navigation—purely widget tree.
  Widget _buildDestination(_AppInitDestination destination) {
    return switch (destination) {
      _DestinationRoleSelection() => const RoleSelectionBootstrap(),
      _DestinationCustomerHome() => const CustomerShellScreen(),
      _DestinationDriverHome() => const DriverShellScreen(),
      _DestinationDriverPending() => const DriverPendingScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppInitDestination>(
      future: _initializationFuture,
      builder:
          (BuildContext context, AsyncSnapshot<_AppInitDestination> snapshot) {
            // Handle initialization errors
            if (snapshot.hasError) {
              debugPrint('App initialization error: ${snapshot.error}');
              debugPrint('Stack trace: ${snapshot.stackTrace}');
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
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Initialization Failed',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'An error occurred while initializing the app. Please tap retry to try again.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: _retryInitialization,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            }

            // While initializing, show splash screen
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
