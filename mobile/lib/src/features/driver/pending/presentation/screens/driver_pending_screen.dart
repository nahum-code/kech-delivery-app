import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/theme/customer_registration_tokens.dart';
import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../auth/login/navigation/driver_auth_navigation.dart';
import '../../../data/driver_onboarding_repository.dart';
import '../../../data/models/driver_status.dart';
import '../../../onboarding/navigation/driver_onboarding_exit.dart';

/// Polls onboarding status until approved, rejected, or suspended.
class DriverPendingScreen extends StatefulWidget {
  const DriverPendingScreen({super.key});

  @override
  State<DriverPendingScreen> createState() => _DriverPendingScreenState();
}

class _DriverPendingScreenState extends State<DriverPendingScreen> {
  Timer? _pollTimer;
  DriverStatus? _status;
  bool _loading = true;
  final int _pollIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _pollTimer = Timer.periodic(Duration(seconds: _pollIntervalSeconds), (_) => _refreshStatus());
  }

  Future<void> _refreshStatus() async {
    final DriverOnboardingRepository repo = context.read<DriverOnboardingRepository>();
    final DriverStatus? status = await repo.fetchOnboardingStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _status = status;
    });

    if (status?.isApproved ?? false) {
      await repo.clearOnboarding();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are approved! Please sign in.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const _DriverApprovedRedirect(),
        ),
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color maroon = CustomerRegistrationTokens.primaryMaroon;
    final DriverStatus? status = _status;

    if (status?.isRejected ?? false) {
      return _RejectedView(reason: status!.rejectionReason, maroon: maroon);
    }
    if (status?.isSuspended ?? false) {
      return _SuspendedView(reason: status!.suspensionReason, maroon: maroon);
    }

    return Scaffold(
      backgroundColor: DriverAppTokens.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: <Widget>[
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: maroon.withValues(alpha: 0.08),
                        border: Border.all(color: maroon.withValues(alpha: 0.2), width: 2),
                      ),
                      child: Icon(Icons.verified_user_outlined, size: 56, color: maroon),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Under Review',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: maroon),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 48,
                      height: 3,
                      color: maroon,
                    ),
                    const Text(
                      "We're currently verifying your documents. This precision check usually takes 2–4 hours.",
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5, color: CustomerRegistrationTokens.labelGray),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We'll notify you as soon as your cockpit is ready.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: CustomerRegistrationTokens.labelGray.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _StepCard(
                      step: 'STEP 1',
                      title: 'Identity Verified',
                      done: status?.phoneVerified ?? false,
                      maroon: maroon,
                    ),
                    const SizedBox(height: 12),
                    _StepCard(
                      step: 'STEP 2',
                      title: 'Background Check',
                      done: status?.documentsSubmitted ?? false,
                      maroon: maroon,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support: support@kech.delivery (TODO)')),
                        );
                      },
                      child: Text(
                        'CONTACT SUPPORT',
                        style: TextStyle(
                          color: maroon,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => DriverOnboardingExit.toRoleSelection(context),
                      child: Text(
                        'CONTINUE AS CUSTOMER INSTEAD',
                        style: TextStyle(
                          color: maroon.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.done,
    required this.maroon,
  });

  final String step;
  final String title;
  final bool done;
  final Color maroon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: done ? maroon : Colors.transparent,
            child: Icon(
              done ? Icons.check : Icons.circle_outlined,
              color: done ? Colors.white : maroon,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(step, style: TextStyle(fontSize: 10, color: maroon.withValues(alpha: 0.6))),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RejectedView extends StatelessWidget {
  const _RejectedView({required this.reason, required this.maroon});
  final String? reason;
  final Color maroon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverAppTokens.screenBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.cancel_outlined, size: 64, color: maroon),
              const SizedBox(height: 16),
              Text('Application Rejected', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: maroon)),
              if (reason != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(reason!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => DriverOnboardingExit.toRoleSelection(context),
                child: Text('Back to role selection', style: TextStyle(color: maroon, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuspendedView extends StatelessWidget {
  const _SuspendedView({required this.reason, required this.maroon});
  final String? reason;
  final Color maroon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverAppTokens.screenBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.block, size: 64, color: maroon),
              const SizedBox(height: 16),
              Text('Account Suspended', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: maroon)),
              if (reason != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(reason!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => DriverOnboardingExit.toRoleSelection(context),
                child: Text('Back to role selection', style: TextStyle(color: maroon, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Routes to driver login after approval (user must sign in with password).
class _DriverApprovedRedirect extends StatelessWidget {
  const _DriverApprovedRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DriverAuthNavigation.replaceWithDriverLogin(context);
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
