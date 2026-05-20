import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../../core/webview/webview_platform_init.dart';
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
  WebViewController? _controller;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    ensureWebViewPlatformInitialized();
    _bootstrapWebView();
  }

  Future<void> _bootstrapWebView() async {
    final String url = widget.checkoutUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _loadError = 'Payment link is missing. Go back and try again.';
        _loading = false;
      });
      return;
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      setState(() {
        _loadError = 'Payment link is invalid. Go back and try again.';
        _loading = false;
      });
      return;
    }

    if (await _preflightHostLookupFailed(uri.host)) {
      if (!mounted) return;
      setState(() {
        _loadError = _dnsFailureMessage(uri.host);
        _loading = false;
      });
      return;
    }

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _loadError = null;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _loadError = _webResourceErrorMessage(error);
            });
          },
          onNavigationRequest: _onNavigation,
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    setState(() => _controller = controller);
    await controller.loadRequest(uri);
  }

  /// True when the device cannot resolve the checkout host before loading the WebView.
  Future<bool> _preflightHostLookupFailed(String host) async {
    if (host == 'localhost' || host == '127.0.0.1') {
      return false;
    }
    try {
      final List<InternetAddress> results = await InternetAddress.lookup(host).timeout(
        const Duration(seconds: 8),
      );
      return results.isEmpty;
    } on TimeoutException {
      return true;
    } on SocketException {
      return true;
    } on OSError {
      return true;
    }
  }

  String _dnsFailureMessage(String host) {
    if (host == '10.0.2.2') {
      return 'Cannot reach the dev server at 10.0.2.2 from this phone. '
          'Use your computer\'s LAN IP in CHAPA_PUBLIC_BASE_URL '
          '(e.g. http://192.168.1.x:8000), same Wi‑Fi as the phone, then restart the backend.';
    }
    final StringBuffer message = StringBuffer(
      'Cannot connect to the payment page. Check Wi‑Fi or mobile data, then tap Retry. '
      'You can also try Open in browser.',
    );
    if (kDebugMode) {
      message.write(
        '\n\n(Dev: DNS could not resolve $host. Emulators need working internet for checkout.chapa.co; '
        'or use CHAPA_MOCK_MODE=1 with CHAPA_PUBLIC_BASE_URL pointing at your machine.)',
      );
    }
    return message.toString();
  }

  String _webResourceErrorMessage(WebResourceError error) {
    final String desc = error.description;
    if (_isDnsLookupFailure(desc, error.errorCode)) {
      final Uri? uri = Uri.tryParse(widget.checkoutUrl.trim());
      return _dnsFailureMessage(uri?.host ?? 'checkout.chapa.co');
    }
    if (desc.isNotEmpty) {
      return 'Chapa could not load ($desc). Check your connection and try again.';
    }
    return 'Chapa could not load. Check your connection and try again.';
  }

  bool _isDnsLookupFailure(String description, int errorCode) {
    if (description.contains('ERR_NAME_NOT_RESOLVED')) {
      return true;
    }
    // Android WebView ERROR_HOST_LOOKUP
    if (errorCode == -2) {
      return true;
    }
    return false;
  }

  NavigationDecision _onNavigation(NavigationRequest request) {
    final Uri uri = Uri.parse(request.url);
    if (_isPaymentReturnUri(uri)) {
      _completeCheckout();
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  bool _isPaymentReturnUri(Uri uri) {
    if (uri.scheme == 'kechdelivery') {
      return true;
    }
    final String path = uri.path.toLowerCase();
    return path.contains('payment/return') ||
        path.contains('return/chapa') ||
        path.endsWith('/payment/return');
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

  Future<void> _openInBrowser() async {
    final Uri? uri = Uri.tryParse(widget.checkoutUrl.trim());
    if (uri == null) return;
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the payment page.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complete payment in the browser, then tap “I already paid — continue”.'),
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
      body: _loadError != null
          ? _ErrorBody(
              message: _loadError!,
              onRetry: _bootstrapWebView,
              onOpenBrowser: _openInBrowser,
              onContinue: _completeCheckout,
            )
          : Stack(
              children: <Widget>[
                if (_controller != null) WebViewWidget(controller: _controller!),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: CustomerCheckoutTokens.primaryMaroon),
                  ),
              ],
            ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.onOpenBrowser,
    required this.onContinue,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenBrowser;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.wifi_off_rounded, size: 48, color: CustomerCheckoutTokens.primaryMaroon),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: CustomerCheckoutTokens.bodyGray, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: CustomerCheckoutTokens.primaryMaroon),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onOpenBrowser,
            child: const Text('Open in browser'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onContinue,
            child: const Text('I already paid — continue'),
          ),
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
  final String url = checkoutUrl.trim();
  if (url.isEmpty) {
    return Future<void>.error(Exception('Payment checkout URL is missing.'));
  }
  return Navigator.of(context).pushReplacement<void, void>(
    MaterialPageRoute<void>(
      builder: (_) => CustomerChapaCheckoutScreen(
        orderId: orderId,
        checkoutUrl: url,
        txRef: txRef,
        initialOrder: order,
      ),
    ),
  );
}
