import 'package:flutter/material.dart';

import '../../../../../shared/contracts/customer_address_save_as.dart';
import '../../../../../shared/contracts/customer_main_tab.dart';
import '../../../../../shared/theme/customer_add_address_tokens.dart';
import '../../../../../shared/widgets/add_address/add_address_labeled_text_field.dart';
import '../../../../../shared/widgets/add_address/add_address_map_preview_card.dart';
import '../../../../../shared/widgets/add_address/add_address_save_as_selector.dart';
import '../../../../../shared/widgets/add_address/add_address_save_button.dart';
import '../../../../../shared/widgets/add_address/add_address_screen_top_bar.dart';
import '../../../auth/login/navigation/customer_auth_navigation.dart';
import '../../../shared/widgets/navigation/customer_main_bottom_nav_bar.dart';

class CustomerAddAddressScreen extends StatefulWidget {
  const CustomerAddAddressScreen({super.key});

  @override
  State<CustomerAddAddressScreen> createState() =>
      _CustomerAddAddressScreenState();
}

class _CustomerAddAddressScreenState extends State<CustomerAddAddressScreen> {
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  CustomerAddressSaveAs _saveAs = CustomerAddressSaveAs.home;
  bool _saving = false;

  @override
  void dispose() {
    _streetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      debugPrint(message);
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onRecenterMap() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) {
        return;
      }
      _toast('Map will follow your device location when search is connected.');
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'customer_add_address',
          context: ErrorDescription('while handling map recenter'),
        ),
      );
      if (mounted) {
        _toast('Could not refresh the map preview.');
      }
    }
  }

  Future<void> _persistAddressDraft() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
  }

  Future<void> _onSaveAddress() async {
    final String street = _streetController.text.trim();
    if (street.isEmpty) {
      _toast('Enter a street address to continue.');
      return;
    }
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await _persistAddressDraft();
      if (!mounted) {
        return;
      }
      CustomerAuthNavigation.finishPostLoginFlowToHome(context);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'customer_add_address',
          context: ErrorDescription('while saving customer address'),
        ),
      );
      if (mounted) {
        _toast('Something went wrong while saving. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _onBottomTab(CustomerMainTab tab) {
    if (tab == CustomerMainTab.profile) {
      return;
    }
    _toast('${tab.name} is coming soon.');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double mapHeight = (size.width * 0.46).clamp(170, 260);

    return Scaffold(
      backgroundColor: CustomerAddAddressTokens.canvas,
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomerMainBottomNavBar(
          current: CustomerMainTab.profile,
          onTabSelected: _onBottomTab,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AddAddressScreenTopBar(
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE4E4E4)),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  CustomerAddAddressTokens.screenHorizontalPadding,
                  16,
                  CustomerAddAddressTokens.screenHorizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AddAddressMapPreviewCard(
                      height: mapHeight,
                      onRecenterPressed: _onRecenterMap,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Where should we deliver?',
                      style: TextStyle(
                        color: CustomerAddAddressTokens.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your precise location for faster delivery.',
                      style: TextStyle(
                        color: CustomerAddAddressTokens.labelGray,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AddAddressLabeledTextField(
                      label: 'Street address',
                      hint: 'e.g. 123 Kinetic Ave',
                      controller: _streetController,
                      textInputAction: TextInputAction.next,
                      suffix: const Icon(
                        Icons.search_rounded,
                        color: CustomerAddAddressTokens.hintGray,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AddAddressLabeledTextField(
                      label: 'Apartment / suite / floor',
                      hint: 'Floor 4, Apt 42B',
                      controller: _unitController,
                      textInputAction: TextInputAction.done,
                      suffix: null,
                    ),
                    const SizedBox(height: 22),
                    AddAddressSaveAsSelector(
                      selected: _saveAs,
                      onChanged: (CustomerAddressSaveAs value) =>
                          setState(() => _saveAs = value),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CustomerAddAddressTokens.screenHorizontalPadding,
                0,
                CustomerAddAddressTokens.screenHorizontalPadding,
                10,
              ),
              child: AddAddressSaveButton(
                loading: _saving,
                onPressed: _onSaveAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
