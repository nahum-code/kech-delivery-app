import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../domain/order_models.dart';

/// Linear journey for an order: Placed → Payment → Searching → Assigned →
/// On the way → Delivered. The currently-active step lights up; everything
/// before it shows as done; anything after shows as pending.
class CustomerOrderJourneyStepper extends StatelessWidget {
  const CustomerOrderJourneyStepper({super.key, required this.order});

  final OrderDetail order;

  // Ordered list of customer-meaningful states from the backend lifecycle:
  // pending → confirmed → searching_driver → assigned → picked_up →
  // delivering → delivered. We collapse `picked_up` and `delivering` into a
  // single "On the way" step because the customer's experience is the same:
  // food is in transit.
  static const List<String> _progressOrder = <String>[
    'placed', // synthetic — order exists at all
    'paid', // payment confirmed
    'confirming', // awaiting admin/agent confirmation
    'searching_driver',
    'assigned',
    'on_the_way',
    'delivered',
  ];

  /// Maps backend `status` (+ payment) into the closest progress index.
  int _currentIndex() {
    if (order.status == 'cancelled') return -1;
    if (order.status == 'delivered') return _progressOrder.indexOf('delivered');
    if (order.status == 'delivering' || order.status == 'picked_up') {
      return _progressOrder.indexOf('on_the_way');
    }
    if (order.status == 'assigned') return _progressOrder.indexOf('assigned');
    if (order.status == 'searching_driver') return _progressOrder.indexOf('searching_driver');
    if (order.status == 'awaiting_confirmation') return _progressOrder.indexOf('confirming');
    if (order.isPaymentPaid) return _progressOrder.indexOf('paid');
    return _progressOrder.indexOf('placed');
  }

  /// Resolves the visual state of step [i]. The payment step (index 1) is
  /// special-cased for pay-on-delivery: it must not be inferred "done" from how
  /// far delivery has progressed — it only completes once the order is paid.
  _StepState _stepState(int i, int currentIndex, {required bool cancelled, required bool pod}) {
    if (cancelled) return _StepState.pending;
    if (i == 1 && pod && !order.isPaymentPaid) return _StepState.pending;
    if (i < currentIndex) return _StepState.done;
    if (i == currentIndex) return _StepState.active;
    return _StepState.pending;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? placed = DateTime.tryParse(order.placedAt)?.toLocal();
    final String placedTime = placed != null ? _formatTime(placed) : '';
    final int currentIndex = _currentIndex();
    final bool cancelled = order.status == 'cancelled';

    // Pay-on-delivery is collected by the driver at handover, so its payment
    // milestone is only "done" once the order is actually paid — never inferred
    // from how far the delivery has progressed.
    final bool pod = order.isPayOnDelivery;

    final List<_StepSpec> steps = <_StepSpec>[
      _StepSpec(
        icon: Icons.check_rounded,
        title: 'Placed',
        time: placedTime,
      ),
      _StepSpec(
        icon: pod ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
        title: pod
            ? (order.isPaymentPaid ? 'Paid on delivery' : 'Pay on delivery')
            : 'Payment confirmed',
        time: order.isPaymentPaid ? placedTime : '',
      ),
      const _StepSpec(
        icon: Icons.fact_check_outlined,
        title: 'Confirming order',
      ),
      const _StepSpec(
        icon: Icons.search_rounded,
        title: 'Searching driver',
      ),
      const _StepSpec(
        icon: Icons.directions_bike_outlined,
        title: 'Driver assigned',
      ),
      const _StepSpec(
        icon: Icons.delivery_dining_rounded,
        title: 'On the way',
      ),
      const _StepSpec(
        icon: Icons.home_outlined,
        title: 'Delivered',
      ),
    ];

    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          _Step(
            icon: steps[i].icon,
            title: steps[i].title,
            time: steps[i].time,
            state: _stepState(i, currentIndex, cancelled: cancelled, pod: pod),
            showLineBelow: i < steps.length - 1 || cancelled,
            lineActive: !cancelled && i < currentIndex,
          ),
        if (cancelled)
          const _Step(
            icon: Icons.cancel_outlined,
            title: 'Cancelled',
            time: '',
            state: _StepState.active,
            showLineBelow: false,
            lineActive: false,
          ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final int h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final String suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $suffix';
  }
}

class _StepSpec {
  const _StepSpec({required this.icon, required this.title, this.time = ''});
  final IconData icon;
  final String title;
  final String time;
}

enum _StepState { done, active, pending }

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    required this.time,
    required this.state,
    required this.showLineBelow,
    required this.lineActive,
  });

  final IconData icon;
  final String title;
  final String time;
  final _StepState state;
  final bool showLineBelow;
  final bool lineActive;

  @override
  Widget build(BuildContext context) {
    final Color circleColor = state == _StepState.pending
        ? CustomerCheckoutTokens.journeyInactive
        : CustomerCheckoutTokens.primaryMaroon;
    final Color titleColor = state == _StepState.active
        ? CustomerCheckoutTokens.primaryMaroon
        : state == _StepState.done
            ? CustomerCheckoutTokens.ink
            : CustomerCheckoutTokens.journeyInactive;
    final FontWeight titleWeight = state == _StepState.pending ? FontWeight.w500 : FontWeight.w800;
    final IconData circleIcon = state == _StepState.done ? Icons.check_rounded : icon;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 36,
            child: Column(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                  child: Icon(circleIcon, color: Colors.white, size: 18),
                ),
                if (showLineBelow)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineActive
                          ? CustomerCheckoutTokens.primaryMaroon
                          : CustomerCheckoutTokens.journeyInactive,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: TextStyle(fontWeight: titleWeight, color: titleColor, fontSize: 15)),
                  if (time.isNotEmpty)
                    Text(time, style: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
