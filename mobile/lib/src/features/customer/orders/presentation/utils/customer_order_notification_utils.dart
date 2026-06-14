import '../../domain/order_models.dart';

/// Maps backend order rows to customer-facing notification copy.
abstract final class CustomerOrderNotificationUtils {
  static bool isNotifiable(OrderSummary order) {
    if (order.status == 'delivered' || order.status == 'cancelled') {
      return false;
    }
    return true;
  }

  static int badgeCount(List<OrderSummary> orders) {
    return orders.where(isNotifiable).length;
  }

  static String headline(OrderSummary order) {
    if (order.isAwaitingOnlinePayment) {
      return 'Payment required';
    }
    return switch (order.status) {
      'pending' => 'Order received',
      'confirmed' => 'Order confirmed',
      'preparing' => 'Preparing your order',
      'ready_for_pickup' => 'Ready for pickup',
      'assigned' => 'Driver assigned',
      'picked_up' => 'Order picked up',
      'delivering' => 'On the way',
      _ => _humanizeStatus(order.status),
    };
  }

  static String subtitle(OrderSummary order) {
    final String ref = order.reference.isNotEmpty ? '#${order.reference}' : 'Order #${order.id}';
    if (order.isAwaitingOnlinePayment) {
      return '$ref · Complete payment for ${order.restaurantName}';
    }
    return '$ref · ${order.restaurantName}';
  }

  static String _humanizeStatus(String status) {
    if (status.isEmpty) {
      return 'Order update';
    }
    return status.replaceAll('_', ' ').split(' ').map((String w) {
      if (w.isEmpty) {
        return w;
      }
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }
}
