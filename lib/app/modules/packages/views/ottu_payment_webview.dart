import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';

/// Result returned when the WebView finishes.
enum OttuPaymentResult { success, failure, cancelled }

class OttuPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String sessionId;

  const OttuPaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.sessionId,
  });

  @override
  State<OttuPaymentWebView> createState() => _OttuPaymentWebViewState();
}

class _OttuPaymentWebViewState extends State<OttuPaymentWebView> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0;
  bool _handled = false; // prevent double-pop from multiple URL callbacks

  // ── URL patterns that signal payment completion ──────────────────────────
  // Adjust these to match the redirect URL your backend returns.
  static const List<String> _successPatterns = [
    'payment-complete',
    'payment/success',
  ];
  static const List<String> _failurePatterns = [
    'payment-failed',
    'payment/failure',
    'payment-cancel',
    'payment/cancel',
  ];

  bool _matchesPattern(String url, List<String> patterns) =>
      patterns.any((p) => url.contains(p));

  void _handleUrlChange(String url) {
    if (_handled) return;
    debugPrint('🌐 WebView URL: $url');
    if (_matchesPattern(url, _successPatterns)) {
      _handled = true;
      Get.back(result: OttuPaymentResult.success);
    } else if (_matchesPattern(url, _failurePatterns)) {
      _handled = true;
      Get.back(result: OttuPaymentResult.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Ask user before leaving the payment screen
        final shouldClose = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Cancel Payment?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to cancel this payment? Your cart will be preserved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Stay',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Cancel Payment',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        if (shouldClose == true) {
          Get.back(result: OttuPaymentResult.cancelled);
        }
        return false; // Always handle ourselves
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Secure Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final shouldClose = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Cancel Payment?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    'Are you sure you want to cancel this payment?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text(
                        'Stay',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Cancel Payment',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldClose == true) {
                Get.back(result: OttuPaymentResult.cancelled);
              }
            },
          ),
          actions: [
            // Security badge
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    'Secured by Ottu',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: _isLoading
                ? LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 3,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.checkoutUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            transparentBackground: false,
            useWideViewPort: true,
            loadWithOverviewMode: true,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() => _isLoading = true);
            if (url != null) _handleUrlChange(url.toString());
          },
          onLoadStop: (controller, url) async {
            setState(() => _isLoading = false);
            if (url != null) _handleUrlChange(url.toString());
          },
          onProgressChanged: (controller, progress) {
            setState(() => _progress = progress / 100.0);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url?.toString() ?? '';
            final scheme = navigationAction.request.url?.scheme ?? '';

            // Deep-link schemes (upi://, intent://, phonepe://, gpay://, etc.)
            // must be launched by the OS, not loaded in the WebView.
            if (scheme != 'http' && scheme != 'https' && scheme != 'about' && scheme.isNotEmpty) {
              debugPrint('🔗 Launching external scheme: $url');
              final uri = Uri.parse(url);
              final canLaunch = await canLaunchUrl(uri);
              if (canLaunch) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                // No UPI app installed — inform the user to use another method
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No UPI app found on this device. Please choose a different payment method (Card / Net Banking).',
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
                debugPrint('⚠️ Cannot launch: $url');
              }
              return NavigationActionPolicy.CANCEL;
            }

            _handleUrlChange(url);
            return NavigationActionPolicy.ALLOW;
          },
          onReceivedError: (controller, request, error) {
            // Ignore errors for redirect URLs and external-scheme URLs
            final url = request.url.toString();
            final scheme = request.url.scheme;
            if (scheme != 'http' && scheme != 'https') return;
            if (_matchesPattern(url, _successPatterns) ||
                _matchesPattern(url, _failurePatterns)) return;
            debugPrint('WebView error: ${error.description} for $url');
          },
        ),
      ),
    );
  }
}
