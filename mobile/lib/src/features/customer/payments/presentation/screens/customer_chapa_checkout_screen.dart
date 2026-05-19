import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../orders/domain/order_models.dart';
import '../../../orders/presentation/screens/customer_payment_pending_screen.dart';

/// In-app Chapa checkout — loads checkout_url; returns to pending screen on completion.
class CustomerChapaCheckoutScreen extends StatefulWidget {
  const CustomerChapaCheckoutScreen({
    super.key,
    required this.orderId,
    required this.checkoutUrl,
    required this.txRef,
    this.initialOrder,
  });

  final int orderId;
  final String checkoutUrl;
  final String txRef;
  final OrderDetail? initialOrder;

  @override
  State<CustomerChapaCheckoutScreen> createState() => _CustomerChapaCheckoutScreenState();
}

class _CustomerChapaCheckoutScreenState extends State<CustomerChapaCheckoutScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: _onNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _onNavigation(NavigationRequest request) {
    final Uri uri = Uri.parse(request.url);
    if (uri.scheme == 'kechdelivery' || uri.host.contains('payment/return')) {
      _completeCheckout();
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _completeCheckout() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => CustomerPaymentPendingScreen(
          orderId: widget.orderId,
          initial: widget.initialOrder,
          txRef: widget.txRef,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerCheckoutTokens.canvas,
      appBar: AppBar(
        backgroundColor: CustomerCheckoutTokens.canvas,
        foregroundColor: CustomerCheckoutTokens.primaryMaroon,
        title: const Text('Chapa checkout', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _completeCheckout(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: CustomerCheckoutTokens.primaryMaroon)),
        ],
      ),
    );
  }
}

/// Opens Chapa after payment init; used from checkout screen.
Future<void> openChapaCheckout(
  BuildContext context, {
  required int orderId,
  required String checkoutUrl,
  required String txRef,
  OrderDetail? order,
}) {
  return Navigator.of(context).pushReplacement<void, void>(
    MaterialPageRoute<void>(
      builder: (_) => CustomerChapaCheckoutScreen(
        orderId: orderId,
        checkoutUrl: checkoutUrl,
        txRef: txRef,
        initialOrder: order,
      ),
    ),
  );
}
