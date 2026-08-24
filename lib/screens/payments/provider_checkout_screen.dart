import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../presentation/resourses/wawat_dark.dart';

const _brand = Color(0xFF017BFE);
const _ink900 = Color(0xFF0F172A);
const _screen = Color(0xFFEEF1F6);

/// How an in-app provider checkout ended.
enum ProviderCheckoutResult {
  /// The WebView reached the merchant return/callback URL — the hosted flow
  /// finished on the provider side. This is NOT proof of a successful charge:
  /// the caller MUST confirm the real status with the backend afterwards.
  returned,

  /// The user closed the sheet (back / close button) before the flow finished.
  cancelled,

  /// The checkout page itself failed to load (network / TLS / HTTP error on the
  /// main frame). The caller should surface an error instead of polling.
  failed,
}

/// Reusable in-app payment checkout.
///
/// Renders a payment provider's hosted `checkout_url` (card / 3-D Secure, and
/// any Apple Pay / Google Pay the provider surfaces on that page) inside an
/// embedded [WebView], instead of bouncing the user to an external browser.
///
/// **Return detection.** The provider hosts checkout on its OWN domain and,
/// when the flow ends, redirects back to our merchant return URL (on our
/// backend). So the screen pops [ProviderCheckoutResult.returned] the moment
/// navigation lands on a host in [returnHosts] (default: our own `wawatair.com`)
/// — and only AFTER the first page has loaded, so the initial `checkoutUrl`
/// (or a `return_url=` query param inside it) can never trigger a false finish.
/// It deliberately does NOT decide success/failure — the backend is the source
/// of truth, so the caller polls the order status once this returns.
///
/// Shared across every paid flow (promotion, listing-quota, verification): give
/// it the `checkout_url` from the pay response and await the result.
class ProviderCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final String title;

  /// Host substrings that mean "the provider redirected back to us" (matched
  /// case-insensitively against `uri.host`). Defaults to our own domain, which
  /// the provider's checkout host never matches. Override with the exact return
  /// host once the provider is known to tighten detection further.
  final List<String> returnHosts;

  /// Extra full-URL substrings that also count as a return (empty by default —
  /// host matching is preferred). Use only exact, provider-specific return
  /// paths; avoid generic tokens like `status=` that appear mid-flow.
  final List<String> returnUrlSnippets;

  const ProviderCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    required this.title,
    this.returnHosts = const ['wawatair.com'],
    this.returnUrlSnippets = const [],
  });

  @override
  State<ProviderCheckoutScreen> createState() => _ProviderCheckoutScreenState();
}

class _ProviderCheckoutScreenState extends State<ProviderCheckoutScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _resolved = false;

  /// Return-URL matching only starts after the first page load, so neither the
  /// initial `checkoutUrl` nor a return target embedded in its query string can
  /// prematurely close the sheet.
  bool _matchable = false;

  /// Set once we've actually loaded a page on the provider's (external) host, so
  /// a return-host match can only mean "the provider redirected back". Guards the
  /// edge where checkout is itself hosted on our own domain (then we never
  /// auto-close and fall back to the user closing + the backend poll).
  bool _sawProviderHost = false;

  @override
  void initState() {
    super.initState();
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(isDark ? WawatDark.bg : Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              _finish(ProviderCheckoutResult.returned);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null && _isReturnUrl(url)) {
              _finish(ProviderCheckoutResult.returned);
            }
          },
          onPageStarted: (url) {
            final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
            if (host.isNotEmpty && !_matchesReturnHost(host)) {
              _sawProviderHost = true;
            }
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            _matchable = true;
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Only a MAIN-FRAME load failure aborts — payment pages routinely
            // emit sub-resource errors we must ignore.
            if (error.isForMainFrame ?? false) {
              _finish(ProviderCheckoutResult.failed);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _matchesReturnHost(String host) =>
      widget.returnHosts.any((h) => host.contains(h.toLowerCase()));

  bool _isReturnUrl(String url) {
    if (!_matchable) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    if (host.isNotEmpty && _sawProviderHost && _matchesReturnHost(host)) {
      return true;
    }
    final lower = url.toLowerCase();
    return widget.returnUrlSnippets.any((s) => lower.contains(s.toLowerCase()));
  }

  void _finish(ProviderCheckoutResult result) {
    if (_resolved || !mounted) return;
    _resolved = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      // Explicit pops (_finish) still go through; this only governs the system
      // back gesture — step back through the provider's pages (e.g. 3-D Secure)
      // instead of tearing down the whole checkout, and only cancel at the root.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          _finish(ProviderCheckoutResult.cancelled);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? WawatDark.bg : _screen,
        appBar: AppBar(
          backgroundColor: isDark ? WawatDark.surface : Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(
              color: isDark ? WawatDark.textPrimary : _ink900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? WawatDark.textPrimary : _ink900,
            ),
            onPressed: () => _finish(ProviderCheckoutResult.cancelled),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 3,
              child: _loading
                  ? const LinearProgressIndicator(
                      minHeight: 3,
                      color: _brand,
                      backgroundColor: Colors.transparent,
                    )
                  : null,
            ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
