import 'package:flutter/material.dart';

import '../../../../shared/theme/driver_task_tokens.dart';
import '../../orders/domain/driver_order_models.dart';

/// New delivery request bottom sheet — matches driver alert mockup.
class DriverNewDeliveryRequestCard extends StatelessWidget {
  const DriverNewDeliveryRequestCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.submitting = false,
    this.secondsLeft = 0,
  });

  final DriverOrderSummary order;
  final int secondsLeft;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool submitting;

  String _formatPayout(DriverOrderSummary o) {
    final String raw = o.driverPayout.isNotEmpty ? o.driverPayout : o.deliveryFee;
    final double? parsed = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (parsed == null) return raw;
    return parsed.toStringAsFixed(2);
  }

  String _pickupLine(DriverOrderSummary o) {
    final String name = o.restaurantName.trim();
    final String addr = o.restaurantAddress.trim();
    if (name.isEmpty) return addr;
    if (addr.isEmpty) return name;
    final String area = addr.split(',').first.trim();
    return '$name · $area';
  }

  String _dropoffLine(DriverOrderSummary o) {
    if (o.dropoffLine.trim().isNotEmpty) return o.dropoffLine.trim();
    return o.customerName.trim();
  }

  @override
  Widget build(BuildContext context) {
    final DriverOrderSummary o = order;
    final String payout = _formatPayout(o);
    final String pickup = _pickupLine(o);
    final String dropoff = _dropoffLine(o);
    final int displaySeconds = secondsLeft.clamp(0, 99);
    final bool isPod = o.paymentMethod == 'pod';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: DriverTaskTokens.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DriverTaskTokens.alertSheetTopRadius),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'NEW DELIVERY REQUEST',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DriverTaskTokens.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.6,
                    height: 1.2,
                  ),
                ),
                if (isPod) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.payments_outlined, size: 16, color: Color(0xFF92400E)),
                        SizedBox(width: 6),
                        Text(
                          'CASH ON DELIVERY',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  payout,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DriverTaskTokens.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 44,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Estimated Payout · Delivery fee',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DriverTaskTokens.subtitleMaroon,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                if (isPod) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Collect ${o.totalAmount} ETB cash from customer on delivery',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF78350F),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: DriverTaskTokens.routeBox,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _RouteRow(
                        icon: const _PickupTargetIcon(),
                        label: 'PICKUP',
                        value: pickup,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 11, top: 10, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 2,
                            height: 22,
                            color: DriverTaskTokens.primaryDark.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                      _RouteRow(
                        icon: Icon(
                          Icons.location_on,
                          size: 22,
                          color: DriverTaskTokens.primaryDark,
                        ),
                        label: 'DROPOFF',
                        value: dropoff,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 35,
                      child: OutlinedButton(
                        onPressed: submitting ? null : onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DriverTaskTokens.primaryDark,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: DriverTaskTokens.declineBorder, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'DECLINE',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 65,
                      child: FilledButton(
                        onPressed: submitting ? null : onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: DriverTaskTokens.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(0, 52),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ACCEPT ORDER',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.4,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'ORDER ID: ${o.reference.startsWith('#') ? o.reference : '#${o.reference}'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DriverTaskTokens.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          if (secondsLeft > 0)
            Positioned(
              top: -22,
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DriverTaskTokens.primaryDark,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${displaySeconds}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PickupTargetIcon extends StatelessWidget {
  const _PickupTargetIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DriverTaskTokens.primaryDark, width: 2),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DriverTaskTokens.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: DriverTaskTokens.labelMaroon,
                  letterSpacing: 1,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.35,
                  color: DriverTaskTokens.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
