import 'package:flutter/material.dart';

import '../../../features/customer/orders/domain/order_models.dart';
import '../../../features/customer/orders/presentation/utils/customer_order_notification_utils.dart';
import '../../theme/customer_home_tokens.dart';

class CustomerHomeNotificationsButton extends StatelessWidget {
  const CustomerHomeNotificationsButton({
    super.key,
    required this.orders,
    required this.onOrderSelected,
    this.onViewAllOrders,
    this.loading = false,
  });

  final List<OrderSummary> orders;
  final ValueChanged<OrderSummary> onOrderSelected;
  final VoidCallback? onViewAllOrders;
  final bool loading;

  int get _badgeCount => CustomerOrderNotificationUtils.badgeCount(orders);

  Future<void> _openSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order updates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: CustomerHomeTokens.primaryMaroon,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live status from your active orders',
                  style: TextStyle(color: CustomerHomeTokens.labelGray, fontSize: 13),
                ),
                const SizedBox(height: 16),
                if (orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No active orders right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CustomerHomeTokens.labelGray),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: orders.length.clamp(0, 8),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final OrderSummary order = orders[index];
                        return Material(
                          color: CustomerHomeTokens.searchFill,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              onOrderSelected(order);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    order.isAwaitingOnlinePayment
                                        ? Icons.payments_outlined
                                        : Icons.delivery_dining_outlined,
                                    color: CustomerHomeTokens.primaryMaroon,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          CustomerOrderNotificationUtils.headline(order),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CustomerOrderNotificationUtils.subtitle(order),
                                          style: TextStyle(
                                            color: CustomerHomeTokens.labelGray,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: CustomerHomeTokens.labelGray),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (onViewAllOrders != null) ...<Widget>[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      onViewAllOrders!();
                    },
                    child: const Text('View all orders'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : () => _openSheet(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.notifications_outlined,
                      color: CustomerHomeTokens.primaryMaroon,
                      size: 28,
                    ),
            ),
            if (_badgeCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: CustomerHomeTokens.primaryMaroon,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      _badgeCount > 9 ? '9+' : '$_badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
