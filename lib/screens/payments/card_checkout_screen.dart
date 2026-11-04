import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum CardCheckoutResult { success, failed, pending, abandoned }

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
