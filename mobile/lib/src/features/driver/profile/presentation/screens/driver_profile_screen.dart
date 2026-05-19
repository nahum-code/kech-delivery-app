import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../auth/data/auth_repository.dart';
import '../../../auth/login/presentation/screens/driver_login_screen.dart';
import '../../../../../shared/theme/driver_shell_navigation_tokens.dart';
import '../../../orders/data/driver_order_repository.dart';
import '../../../orders/domain/driver_order_models.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _status;
  DriverAvailability? _availability;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final String token = context.read<AuthRepository>().currentSession!.accessToken;
    final DriverOrderRepository repo = context.read<DriverOrderRepository>();
    final results = await Future.wait(<Future<Object?>>[
      repo.fetchDriverStatus(accessToken: token),
      repo.fetchAvailability(accessToken: token),
    ]);
    if (!mounted) return;
    setState(() {
      _status = results[0]! as Map<String, dynamic>;
      _availability = results[1]! as DriverAvailability;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await context.read<AuthRepository>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DriverLoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String approval = _status?['approval_status'] as String? ?? '—';
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: DriverShellNavigationTokens.primary,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Driver',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Status: ${approval.toUpperCase()}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (_availability != null)
                        Text(
                          'Availability: ${_availability!.operationalStatus.toUpperCase()}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.delivery_dining),
                          title: const Text('Active deliveries'),
                          trailing: Text('${_availability?.activeDeliveryCount ?? 0}'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.account_balance_wallet_outlined),
                          title: const Text('Earnings (estimated)'),
                          subtitle: const Text('Based on completed delivery fees — payout TBD'),
                          trailing: const Text('—'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
