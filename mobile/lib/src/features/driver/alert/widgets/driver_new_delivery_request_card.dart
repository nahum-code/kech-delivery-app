import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/theme/driver_task_tokens.dart';
import '../../orders/domain/driver_order_models.dart';

/// New delivery request card — matches alert mockup (countdown, route, accept/decline).
class DriverNewDeliveryRequestCard extends StatefulWidget {
  const DriverNewDeliveryRequestCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.submitting = false,
    this.countdownSeconds = 30,
  });

  final DriverOrderSummary order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool submitting;
  final int countdownSeconds;

  @override
  State<DriverNewDeliveryRequestCard> createState() => _DriverNewDeliveryRequestCardState();
}

class _DriverNewDeliveryRequestCardState extends State<DriverNewDeliveryRequestCard> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.countdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DriverOrderSummary o = widget.order;
    final String payout = o.deliveryFee.isNotEmpty ? o.deliveryFee : o.totalAmount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Transform.translate(
              offset: const Offset(0, -36),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DriverTaskTokens.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_secondsLeft}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const Text(
              'NEW DELIVERY REQUEST',
              style: TextStyle(
                color: DriverTaskTokens.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$payout ETB',
              style: const TextStyle(
                color: DriverTaskTokens.primary,
                fontWeight: FontWeight.w800,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estimated payout · delivery fee',
              style: TextStyle(color: DriverTaskTokens.primary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DriverTaskTokens.routeBox,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: <Widget>[
                  _RouteRow(
                    icon: Icons.my_location_outlined,
                    label: 'PICKUP',
                    value: o.restaurantName.isNotEmpty
                        ? '${o.restaurantName} · ${o.restaurantAddress}'
                        : o.restaurantAddress,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 11),
                    height: 20,
                    width: 2,
                    color: DriverTaskTokens.primary.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 12),
                  _RouteRow(
                    icon: Icons.location_on_outlined,
                    label: 'DROPOFF',
                    value: o.dropoffLine.isNotEmpty ? o.dropoffLine : o.customerName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.submitting ? null : widget.onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DriverTaskTokens.primary,
                      side: const BorderSide(color: DriverTaskTokens.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('DECLINE', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.submitting ? null : widget.onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: DriverTaskTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: widget.submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ACCEPT ORDER', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ORDER ID: ${o.reference}',
              style: const TextStyle(color: DriverTaskTokens.muted, fontSize: 11, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 22, color: DriverTaskTokens.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: DriverTaskTokens.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
