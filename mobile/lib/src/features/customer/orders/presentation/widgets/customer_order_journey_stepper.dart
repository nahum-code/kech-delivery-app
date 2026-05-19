import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../domain/order_models.dart';

class CustomerOrderJourneyStepper extends StatelessWidget {
  const CustomerOrderJourneyStepper({super.key, required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final DateTime? placed = DateTime.tryParse(order.placedAt)?.toLocal();
    final String placedTime = placed != null ? _formatTime(placed) : '';

    final bool paymentDone = order.isPaymentPaid;
    final bool searchingDriver = paymentDone &&
        !<String>['assigned', 'picked_up', 'delivering', 'delivered'].contains(order.status);

    return Column(
      children: <Widget>[
        _Step(
          icon: Icons.check_rounded,
          title: 'Placed',
          time: placedTime,
          state: _StepState.done,
          showLineBelow: true,
          lineActive: paymentDone,
        ),
        _Step(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Payment confirmed',
          time: paymentDone ? placedTime : '',
          state: paymentDone ? _StepState.active : _StepState.pending,
          showLineBelow: true,
          lineActive: searchingDriver || _driverAssigned,
        ),
        _Step(
          icon: Icons.search_rounded,
          title: 'Searching driver',
          time: '',
          state: searchingDriver
              ? _StepState.active
              : _driverAssigned
                  ? _StepState.done
                  : _StepState.pending,
          showLineBelow: false,
          lineActive: false,
        ),
      ],
    );
  }

  bool get _driverAssigned =>
      <String>['assigned', 'picked_up', 'delivering', 'delivered'].contains(order.status);

  String _formatTime(DateTime dt) {
    final int h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final String suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $suffix';
  }
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
                  child: Icon(
                    state == _StepState.done && icon == Icons.search_rounded ? Icons.check_rounded : icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                if (showLineBelow)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineActive ? CustomerCheckoutTokens.primaryMaroon : CustomerCheckoutTokens.journeyInactive,
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
