import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../app/role_selection_bootstrap.dart';
import '../../../../../shared/theme/customer_profile_tokens.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/widgets/profile/profile_delete_account_button.dart';
import '../../../add_address/presentation/screens/customer_add_address_screen.dart';
import '../../data/customer_profile_avatar_store.dart';
import '../../data/customer_saved_addresses_store.dart';
import '../widgets/customer_profile_account_tile.dart';
import '../widgets/customer_profile_expandable_section.dart';
import '../widgets/customer_profile_preferences_group.dart';
import 'customer_update_email_screen.dart';

/// Customer profile — account, preferences, support (production mockup).
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  String _fullName = 'Customer';
  String _phone = '';
  String _email = '';
  String _memberSince = '';
  String? _avatarPath;
  List<CustomerSavedAddress> _savedAddresses = <CustomerSavedAddress>[];
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _loading = true;
  bool _avatarBusy = false;

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
      final List<CustomerSavedAddress> addresses = await CustomerSavedAddressesStore().loadAll();
      final String? avatarPath = await CustomerProfileAvatarStore().loadPath(session.userId);
      if (!mounted) return;
      final Map<String, dynamic>? profile = me?['profile'] as Map<String, dynamic>?;
      final String phone = me?['phone'] as String? ?? '';
      final String name = profile?['full_name'] as String? ?? 'Customer';
      final String email = profile?['email'] as String? ?? '';
      final String createdAt = me?['created_at'] as String? ?? '';
      setState(() {
        _fullName = name;
        _phone = phone;
        _email = email.trim();
        _avatarPath = avatarPath;
        _memberSince = _formatMemberSince(createdAt);
        _savedAddresses = addresses;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _emailDisplay => _email.isNotEmpty ? _email : 'Not set';

  void _toast(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickAvatar() async {
    if (_avatarBusy) {
      return;
    }
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Profile photo',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: CustomerProfileTokens.primaryMaroon),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: CustomerProfileTokens.primaryMaroon),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) {
      return;
    }
    setState(() => _avatarBusy = true);
    try {
      final XFile? file = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (file == null || !mounted) {
        return;
      }
      final int? userId = context.read<AuthRepository>().currentSession?.userId;
      if (userId != null) {
        await CustomerProfileAvatarStore().savePath(userId, file.path);
      }
      setState(() => _avatarPath = file.path);
    } catch (_) {
      if (mounted) {
        _toast('Could not update profile photo.');
      }
    } finally {
      if (mounted) {
        setState(() => _avatarBusy = false);
      }
    }
  }

  Future<void> _openUpdateEmail() async {
    final String? updated = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CustomerUpdateEmailScreen(initialEmail: _email),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }
    setState(() => _email = updated);
    _toast('Recovery email saved.');
  }

  String _formatMemberSince(String createdAt) {
    if (createdAt.isEmpty) {
      return '—';
    }
    final DateTime? parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return createdAt.split('T').first;
    }
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.year}';
  }

  ({Color bg, Color fg}) _chipColorsForLabel(String label) {
    switch (label.trim().toUpperCase()) {
      case 'WORK':
        return (bg: CustomerProfileTokens.workChipFill, fg: CustomerProfileTokens.workChipText);
      case 'OTHER':
        return (bg: const Color(0xFFE8E8E8), fg: CustomerProfileTokens.titleInk);
      default:
        return (bg: CustomerProfileTokens.homeChipFill, fg: CustomerProfileTokens.homeChipText);
    }
  }

  Future<void> _openAddAddress() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CustomerAddAddressScreen()),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _signOut() async {
    await context.read<AuthRepository>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const RoleSelectionBootstrap()),
      (_) => false,
    );
  }

  Widget _savedAddressesCollapsedSummary() {
    if (_savedAddresses.isEmpty) {
      return const CustomerProfileAddressTags();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _savedAddresses
          .map((CustomerSavedAddress a) {
            final ({Color bg, Color fg}) colors = _chipColorsForLabel(a.label);
            return CustomerProfileTag(label: a.label, background: colors.bg, foreground: colors.fg);
          })
          .toList(growable: false),
    );
  }

  List<Widget> _savedAddressesExpandedChildren() {
    if (_savedAddresses.isEmpty) {
      return <Widget>[
        const CustomerProfileInfoRow(
          label: 'NO SAVED ADDRESSES',
          value: 'Add a home or work address for faster checkout.',
        ),
        _addAddressLink(),
      ];
    }
    return <Widget>[
      ..._savedAddresses.map((CustomerSavedAddress a) {
        final ({Color bg, Color fg}) colors = _chipColorsForLabel(a.label);
        return CustomerProfileAddressEntryRow(
          label: a.label,
          addressLine: a.displayLine,
          chipBackground: colors.bg,
          chipForeground: colors.fg,
        );
      }),
      _addAddressLink(),
    ];
  }

  Widget _addAddressLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _openAddAddress,
        icon: const Icon(Icons.add_location_alt_outlined, size: 18),
        label: const Text('Add address'),
        style: TextButton.styleFrom(
          foregroundColor: CustomerProfileTokens.primaryMaroon,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
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
                  const SizedBox(height: 8),
                  const Text('Profile', style: CustomerProfileTokens.appBarTitle),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: _avatarBusy ? null : _pickAvatar,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              width: CustomerProfileTokens.avatarRadius * 2,
                              height: CustomerProfileTokens.avatarRadius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CustomerProfileTokens.avatarFill,
                                border: Border.all(color: CustomerProfileTokens.primaryMaroon, width: 2),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _avatarPath != null
                                  ? Image.file(
                                      File(_avatarPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.person_rounded,
                                        size: 40,
                                        color: CustomerProfileTokens.primaryMaroon,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      size: 40,
                                      color: CustomerProfileTokens.primaryMaroon,
                                    ),
                            ),
                            if (_avatarBusy)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: Colors.black26,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: CustomerProfileTokens.primaryMaroon,
                                      ),
                                    ),
                                  ),
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
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: CustomerProfileTokens.primaryMaroon,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_fullName, style: CustomerProfileTokens.userName),
                            const SizedBox(height: 4),
                            if (_phone.isNotEmpty)
                              Text(_phone, style: CustomerProfileTokens.userEmail)
                            else if (_email.isNotEmpty)
                              Text(_email, style: CustomerProfileTokens.userEmail),
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
                  CustomerProfileExpandableSection(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal info',
                    collapsedSummary: Text(
                      _email.isNotEmpty
                          ? _email
                          : (_phone.isNotEmpty ? _phone : _fullName),
                      style: const TextStyle(
                        color: CustomerProfileTokens.subtitleGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: <Widget>[
                      CustomerProfileInfoRow(label: 'FULL NAME', value: _fullName, icon: Icons.badge_outlined),
                      CustomerProfileInfoRow(
                        label: 'PHONE',
                        value: _phone.isNotEmpty ? _phone : 'Not set',
                        icon: Icons.phone_outlined,
                      ),
                      CustomerProfileInfoRow(
                        label: 'EMAIL',
                        value: _emailDisplay,
                        icon: Icons.mail_outline_rounded,
                        onTap: _openUpdateEmail,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: CustomerProfileTokens.subtitleGray,
                          size: 22,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Signup email used for password reset. Tap to update.',
                          style: TextStyle(
                            color: CustomerProfileTokens.subtitleGray,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                      CustomerProfileInfoRow(
                        label: 'MEMBER SINCE',
                        value: _memberSince,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                  CustomerProfileExpandableSection(
                    icon: Icons.location_on_outlined,
                    title: 'Saved addresses',
                    collapsedSummary: _savedAddressesCollapsedSummary(),
                    children: _savedAddressesExpandedChildren(),
                  ),
                  CustomerProfileExpandableSection(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payment methods',
                    collapsedSummary: const Text(
                      'Chapa · ETB',
                      style: TextStyle(
                        color: CustomerProfileTokens.subtitleGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: <Widget>[
                      const CustomerProfileInfoRow(
                        label: 'CHECKOUT',
                        value: 'Pay with Chapa when you place an order (mobile money & cards).',
                        icon: Icons.payments_outlined,
                      ),
                      const CustomerProfileInfoRow(
                        label: 'SAVED CARDS',
                        value: 'No cards stored on this device. Payment is completed securely at checkout.',
                        icon: Icons.credit_card_outlined,
                      ),
                      const CustomerProfileInfoRow(
                        label: 'CURRENCY',
                        value: 'Ethiopian Birr (ETB)',
                        icon: Icons.currency_exchange_rounded,
                      ),
                    ],
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
                  const SizedBox(height: 8),
                  ProfileDeleteAccountButton(
                    foregroundColor: Colors.red.shade700,
                    onDeleted: () {
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(builder: (_) => const RoleSelectionBootstrap()),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
