import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Result reported by the bank's hosted page via the app deep link
/// `wawatair://payment/result?status=success|failed|pending`. The link also
/// carries an id param that differs per feature (`?promotion=` for promos,
/// `?order=` for listing-quota) — this screen ignores it and reads only
/// `status`, so it works for both without change.
///
/// It is only a hint — the caller MUST confirm the real state server-side
/// afterwards (`GET /promotions/{id}` or `GET /listing-quota/orders/{id}`),
/// keyed by its own id, not by the deep link. [abandoned] means the user closed
/// the WebView before the bank redirected (no verdict yet).
enum CardCheckoutResult { success, failed, pending, abandoned }

/// In-app WebView that hosts the Kapital 3-D Secure payment page.
///
/// The PAN is entered on the bank's own page — the app never touches card data.
/// We watch navigation for the `wawatair://payment/result` deep link the bank
/// redirects to when the flow ends, read its `status`, and pop with it.
class CardCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final String title;

  const CardCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    required this.title,
  });

  @override
  State<CardCheckoutScreen> createState() => _CardCheckoutScreenState();
}

class _CardCheckoutScreenState extends State<CardCheckoutScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _finished = false;

  static const String _resultPrefix = 'wawatair://payment/result';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(_resultPrefix)) {
              _finish(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  /// Maps the deep link's `status` query param to a [CardCheckoutResult] and
  /// pops once. Guarded so a double redirect can't pop twice.
  void _finish(String url) {
    if (_finished) return;
    _finished = true;
    final status =
        Uri.tryParse(url)?.queryParameters['status']?.toLowerCase();
    final result = switch (status) {
      'success' => CardCheckoutResult.success,
      'failed' => CardCheckoutResult.failed,
      'pending' => CardCheckoutResult.pending,
      _ => CardCheckoutResult.pending,
    };
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Closing without a bank redirect = the user abandoned the payment.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(CardCheckoutResult.abandoned);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context).pop(CardCheckoutResult.abandoned),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
