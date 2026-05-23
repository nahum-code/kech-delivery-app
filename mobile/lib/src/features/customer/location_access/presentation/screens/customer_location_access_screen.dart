import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_location_access_tokens.dart';
import '../../../../../shared/widgets/location_access/location_access_bottom_card.dart';
import '../../../../../shared/widgets/location_access/location_access_brand_header.dart';
import '../../../../../shared/widgets/location_access/location_access_hero_copy_block.dart';
import '../../../../../shared/widgets/location_access/location_access_map_backdrop.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../auth/login/navigation/customer_auth_navigation.dart';
import '../../application/customer_location_onboarding_store.dart';
import '../../application/customer_location_permission_coordinator.dart';
import '../../../add_address/presentation/screens/customer_add_address_screen.dart';

class CustomerLocationAccessScreen extends StatefulWidget {
  const CustomerLocationAccessScreen({super.key});

  @override
  State<CustomerLocationAccessScreen> createState() => _CustomerLocationAccessScreenState();
}

class _CustomerLocationAccessScreenState extends State<CustomerLocationAccessScreen> {
  bool _allowLocationBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfAlreadyComplete());
  }

  Future<void> _redirectIfAlreadyComplete() async {
    final AuthRepository auth = context.read<AuthRepository>();
    if (await CustomerLocationOnboardingStore.shouldSkipPrompt(auth: auth)) {
      if (!mounted) {
        return;
      }
      CustomerAuthNavigation.replaceWithCustomerHome(context);
    }
  }

  void _toast(BuildContext context, String message) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint(message);
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markLocationChoiceComplete() async {
    await context.read<AuthRepository>().markCustomerLocationOnboardingComplete();
  }

  Future<void> _finishToHome() async {
    await _markLocationChoiceComplete();
    if (!mounted) {
      return;
    }
    CustomerAuthNavigation.replaceWithCustomerHome(context);
  }

  Future<void> _onAllowLocation() async {
    if (_allowLocationBusy) {
      return;
    }
    setState(() => _allowLocationBusy = true);
    final CustomerLocationWhenInUseOutcome outcome = await CustomerLocationPermissionCoordinator.requestWhenInUse();
    if (!mounted) {
      return;
    }
    setState(() => _allowLocationBusy = false);

    switch (outcome) {
      case CustomerLocationWhenInUseOutcome.granted:
        await _finishToHome();
        return;
      case CustomerLocationWhenInUseOutcome.denied:
        _toast(context, 'Location is off. You can enable it in settings or pick an address manually.');
        await _finishToHome();
        return;
      case CustomerLocationWhenInUseOutcome.permanentlyDenied:
        await _offerOpenSettings(context);
        return;
      case CustomerLocationWhenInUseOutcome.restricted:
        _toast(context, 'Location is restricted on this device. Try selecting an address manually.');
        await _finishToHome();
        return;
      case CustomerLocationWhenInUseOutcome.serviceError:
        _toast(context, 'We could not request location access. Please try again or select manually.');
        return;
    }
  }

  Future<void> _offerOpenSettings(BuildContext context) async {
    final bool? shouldOpen = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Location blocked'),
          content: const Text(
            'Kech needs location access for routing. Open system settings to enable it, or choose an address manually.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
    if (!context.mounted) {
      return;
    }
    if (shouldOpen != true) {
      await _finishToHome();
      return;
    }
    final bool opened = await CustomerLocationPermissionCoordinator.openSystemSettings();
    if (!context.mounted) {
      return;
    }
    if (!opened) {
      _toast(context, 'Could not open settings.');
    }
  }

  Future<void> _onSelectManually() async {
    await _markLocationChoiceComplete();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const CustomerAddAddressScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerLocationAccessTokens.card,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const LocationAccessMapBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CustomerLocationAccessTokens.screenHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 8),
                  const LocationAccessBrandHeader(),
                  const SizedBox(height: 28),
                  const LocationAccessHeroCopyBlock(),
                  const Spacer(),
                  LocationAccessBottomCard(
                    allowLocationLoading: _allowLocationBusy,
                    onAllowLocation: _onAllowLocation,
                    onSelectManually: _onSelectManually,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
