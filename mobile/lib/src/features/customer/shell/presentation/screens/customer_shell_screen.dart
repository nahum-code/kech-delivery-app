import 'package:flutter/material.dart';

import '../../../../../shared/contracts/customer_main_tab.dart';
import '../../../../../shared/theme/customer_home_tokens.dart';
import '../../../home/presentation/screens/customer_home_screen.dart';
import '../../../inbox/presentation/screens/customer_inbox_screen.dart';
import '../../../orders/presentation/screens/customer_orders_list_screen.dart';
import '../../../profile/presentation/screens/customer_profile_screen.dart';
import '../../../shared/widgets/navigation/customer_main_bottom_nav_bar.dart';

/// Customer main shell — home, orders, inbox, profile with shared bottom nav.
class CustomerShellScreen extends StatefulWidget {
  const CustomerShellScreen({
    super.key,
    this.deliverAddressLine = 'Home',
    this.initialTab = CustomerMainTab.home,
  });

  final String deliverAddressLine;
  final CustomerMainTab initialTab;

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  late CustomerMainTab _tab;
  final GlobalKey<CustomerOrdersListScreenState> _ordersKey =
      GlobalKey<CustomerOrdersListScreenState>();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  void _onTabSelected(CustomerMainTab tab) {
    setState(() => _tab = tab);
    if (tab == CustomerMainTab.orders) {
      _ordersKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeTokens.canvas,
      body: IndexedStack(
        index: _tab.index,
        children: <Widget>[
          CustomerHomeScreen(
            deliverAddressLine: widget.deliverAddressLine,
            embeddedInShell: true,
            onViewAllOrders: () => _onTabSelected(CustomerMainTab.orders),
          ),
          CustomerOrdersListScreen(key: _ordersKey, embeddedInShell: true),
          const CustomerInboxScreen(),
          const CustomerProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomerMainBottomNavBar(
          current: _tab,
          uppercaseLabels: true,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
