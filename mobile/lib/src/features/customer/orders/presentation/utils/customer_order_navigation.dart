import 'package:flutter/material.dart';

import '../../domain/order_models.dart';
import '../screens/customer_order_detail_screen.dart';
import '../screens/customer_order_tracking_screen.dart';
import '../screens/customer_payment_pending_screen.dart';

/// Routes customer to the correct order surface for its lifecycle state.
abstract final class CustomerOrderNavigation {
  static void openOrder(BuildContext context, {required int orderId, OrderDetail? snapshot}) {
    if (snapshot != null) {
      if (snapshot.isPaymentPending) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => CustomerPaymentPendingScreen(orderId: orderId, initial: snapshot),
          ),
        );
        return;
      }
      if (!snapshot.isTerminal) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => CustomerOrderTrackingScreen(orderId: orderId, initial: snapshot),
          ),
        );
        return;
      }
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => CustomerOrderDetailScreen(orderId: orderId)),
    );
  }

  static void openSummary(BuildContext context, OrderSummary summary) {
    if (summary.isPaymentPending) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => CustomerPaymentPendingScreen(orderId: summary.id)),
      );
      return;
    }
    if (summary.isActiveForTracking) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => CustomerOrderTrackingScreen(orderId: summary.id)),
      );
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => CustomerOrderDetailScreen(orderId: summary.id)),
    );
  }
}
