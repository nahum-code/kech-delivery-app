import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/role_selection_bootstrap.dart';
import '../../../../../shared/theme/customer_profile_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../widgets/customer_profile_account_tile.dart';
import '../widgets/customer_profile_preferences_group.dart';

/// Customer profile — account, preferences, support (production mockup).
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String _fullName = 'Customer';
  String _subtitle = '';
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final AuthRepository auth = context.read<AuthRepository>();
    final session = auth.currentSession;
    if (session == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final Map<String, dynamic>? me = await auth.fetchMe(accessToken: session.accessToken);
      if (!mounted) return;
      final Map<String, dynamic>? profile = me?['profile'] as Map<String, dynamic>?;
      final String phone = me?['phone'] as String? ?? '';
      final String name = profile?['full_name'] as String? ?? 'Customer';
      setState(() {
        _fullName = name;
        _subtitle = _formatSubtitle(name, phone);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _formatSubtitle(String name, String phone) {
    if (phone.isNotEmpty) {
      return phone;
    }
    final String local = name.trim().toLowerCase().replaceAll(' ', '.');
    if (local.isEmpty) {
      return 'customer@kech.delivery';
    }
    return '$local@email.com';
  }

  Future<void> _signOut() async {
    await context.read<AuthRepository>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleSelectionBootstrap()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CustomerProfileTokens.canvas,
      child: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: CustomerProfileTokens.primaryMaroon))
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  CustomerProfileTokens.screenPadding,
                  4,
                  CustomerProfileTokens.screenPadding,
                  24,
                ),
                children: <Widget>[
                  const Center(child: Text('CUSTOMER – PROFILE', style: CustomerProfileTokens.screenCaption)),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu_rounded, color: CustomerProfileTokens.primaryMaroon),
                      ),
                      const Expanded(
                        child: Text('Profile', style: CustomerProfileTokens.appBarTitle),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined, color: CustomerProfileTokens.primaryMaroon),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: CustomerProfileTokens.avatarRadius * 2,
                            height: CustomerProfileTokens.avatarRadius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CustomerProfileTokens.avatarFill,
                              border: Border.all(color: CustomerProfileTokens.primaryMaroon, width: 2),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: CustomerProfileTokens.primaryMaroon,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: CustomerProfileTokens.editBadgeRadius * 2,
                              height: CustomerProfileTokens.editBadgeRadius * 2,
                              decoration: const BoxDecoration(
                                color: CustomerProfileTokens.iconTileSurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: CustomerProfileTokens.primaryMaroon,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_fullName, style: CustomerProfileTokens.userName),
                            const SizedBox(height: 4),
                            Text(_subtitle, style: CustomerProfileTokens.userEmail),
                            const SizedBox(height: 10),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: CustomerProfileTokens.eliteBadgeFill,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.verified_rounded, size: 14, color: CustomerProfileTokens.primaryMaroon),
                                    SizedBox(width: 4),
                                    Text(
                                      'Elite member',
                                      style: TextStyle(
                                        color: CustomerProfileTokens.primaryMaroon,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('Account', style: CustomerProfileTokens.sectionTitle),
                  const SizedBox(height: 12),
                  CustomerProfileAccountTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal info',
                    onTap: () {},
                  ),
                  CustomerProfileAccountTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved addresses',
                    subtitle: const CustomerProfileAddressTags(),
                    onTap: () {},
                  ),
                  CustomerProfileAccountTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payment methods',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Visa •• 42',
                          style: TextStyle(
                            color: CustomerProfileTokens.subtitleGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: CustomerProfileTokens.chevronGray, size: 22),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Preferences', style: CustomerProfileTokens.sectionTitle),
                  const SizedBox(height: 12),
                  CustomerProfilePreferencesGroup(
                    pushEnabled: _pushEnabled,
                    emailEnabled: _emailEnabled,
                    onPushChanged: (bool v) => setState(() => _pushEnabled = v),
                    onEmailChanged: (bool v) => setState(() => _emailEnabled = v),
                  ),
                  const SizedBox(height: 20),
                  const Text('Support', style: CustomerProfileTokens.sectionTitle),
                  const SizedBox(height: 12),
                  CustomerProfileAccountTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help center',
                    onTap: () {},
                  ),
                  CustomerProfileAccountTile(
                    icon: Icons.policy_outlined,
                    title: 'Terms & privacy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomerProfileTokens.primaryMaroon,
                        side: const BorderSide(color: CustomerProfileTokens.primaryMaroon, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
