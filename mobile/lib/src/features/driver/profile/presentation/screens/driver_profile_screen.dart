import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/role_selection_bootstrap.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../../../shared/theme/driver_profile_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';
import '../../../../../shared/widgets/profile/profile_delete_account_button.dart';
import '../widgets/driver_profile_hero_header.dart';
import '../widgets/driver_profile_settings_tile.dart';

/// Driver profile — hero header, vehicle, earnings, settings, sign out.
class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String _fullName = 'Driver';
  String _phone = '';
  String _approval = 'pending';
  String _vehicleType = '';
  int _userId = 0;
  int _completedCount = 0;
  double _earningsBalance = 0;
  double _cashDebt = 0;
  bool _pushNotifications = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final AuthRepository auth = context.read<AuthRepository>();
    final session = auth.currentSession;
    if (session == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final DriverOrderRepository repo = context.read<DriverOrderRepository>();
      final results = await Future.wait(<Future<Object?>>[
        auth.fetchMe(accessToken: session.accessToken),
        repo.fetchDriverStatus(accessToken: session.accessToken),
        repo.fetchOrders(accessToken: session.accessToken, status: 'delivered'),
        repo.fetchMyBalance(accessToken: session.accessToken),
      ]);
      if (!mounted) return;
      final Map<String, dynamic>? me = results[0] as Map<String, dynamic>?;
      final Map<String, dynamic> status = results[1]! as Map<String, dynamic>;
      final List<DriverOrderSummary> completed = results[2]! as List<DriverOrderSummary>;
      final Map<String, dynamic> balanceData = results[3]! as Map<String, dynamic>;
      final Map<String, dynamic>? profile = me?['profile'] as Map<String, dynamic>?;
      setState(() {
        _userId = me?['id'] as int? ?? 0;
        _phone = me?['phone'] as String? ?? '';
        _fullName = profile?['full_name'] as String? ?? 'Driver';
        _vehicleType = profile?['vehicle_type'] as String? ?? '';
        _approval = status['approval_status'] as String? ?? profile?['approval_status'] as String? ?? 'pending';
        _completedCount = completed.length;
        _earningsBalance = double.tryParse('${balanceData['balance']}') ?? 0;
        _cashDebt = double.tryParse('${balanceData['debt']}') ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String get _driverId => 'KD-${_userId.toString().padLeft(5, '0')}';

  String get _tierLabel {
    if (_approval == 'approved' && _completedCount >= 100) {
      return 'GOLD TIER DRIVER';
    }
    if (_approval == 'approved') {
      return 'VERIFIED DRIVER';
    }
    return _approval.toUpperCase();
  }

  String get _deliveriesLabel {
    if (_completedCount >= 1000) {
      final double k = _completedCount / 1000;
      return k >= 10 ? '${k.toStringAsFixed(0)}k' : '${k.toStringAsFixed(1)}k';
    }
    return '$_completedCount';
  }

  String get _vehicleLine {
    final String type = switch (_vehicleType) {
      'sedan' => 'Sedan',
      'motorbike' => 'Motorbike',
      _ => 'Vehicle',
    };
    if (_phone.isNotEmpty) {
      return '$type · $_phone';
    }
    return type;
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
      color: DriverProfileTokens.screenBackground,
      child: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: DriverProfileTokens.primary))
            : RefreshIndicator(
                color: DriverProfileTokens.primary,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DriverProfileHeroHeader(
                      fullName: _displayName,
                      driverId: _driverId,
                      tierLabel: _tierLabel,
                      deliveriesLabel: _deliveriesLabel,
                      isApproved: _approval == 'approved',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _vehicleCard(),
                          const SizedBox(height: 24),
                          _earningsSection(),
                          const SizedBox(height: 24),
                          DriverProfileSettingsTile(
                            icon: Icons.notifications_outlined,
                            title: 'Push Notifications',
                            value: _pushNotifications,
                            onChanged: (bool v) => setState(() => _pushNotifications = v),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _signOut,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DriverProfileTokens.primary,
                              side: const BorderSide(color: DriverProfileTokens.primary),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sign out',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                  ],
                ),
              ),
      ),
    );
  }

  String get _displayName {
    final String name = _fullName.trim();
    if (name.isEmpty) return 'Driver';
    final List<String> parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    final String last = parts.last;
    return '${parts.first} ${last.isNotEmpty ? '${last[0].toUpperCase()}.' : ''}';
  }

  Widget _vehicleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverProfileTokens.cardSurface,
        borderRadius: BorderRadius.circular(DriverProfileTokens.cardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DriverProfileTokens.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car_filled_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'VEHICLE STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: DriverProfileTokens.labelMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _vehicleLine,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: DriverProfileTokens.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Earnings Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: DriverProfileTokens.ink,
                ),
              ),
            ),
            Text(
              'THIS WEEK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: DriverProfileTokens.labelMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DriverProfileTokens.cardSurface,
            borderRadius: BorderRadius.circular(DriverProfileTokens.cardRadius),
            border: const Border(left: BorderSide(color: DriverProfileTokens.earningsAccent, width: 4)),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 13,
                        color: DriverProfileTokens.bodyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ETB ${_earningsBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        color: DriverProfileTokens.primary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DriverProfileTokens.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 26),
              ),
            ],
          ),
        ),
        if (_cashDebt > 0) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(DriverProfileTokens.cardRadius),
              border: const Border(left: BorderSide(color: Color(0xFFDC2626), width: 4)),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Cash owed to platform',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ETB ${_cashDebt.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: Color(0xFFDC2626),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Settle this amount with the platform from your cash-on-delivery collections.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_outlined, color: Colors.white, size: 26),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
