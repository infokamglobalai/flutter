import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class PaymentWebviewModal extends StatefulWidget {
  final String paymentUrl;
  final String title;

  const PaymentWebviewModal({
    super.key,
    required this.paymentUrl,
    this.title = 'Complete Payment',
  });

  static Future<bool?> open({
    required String paymentUrl,
    String title = 'Complete Payment',
  }) {
    return Get.to<bool>(
      () => PaymentWebviewModal(paymentUrl: paymentUrl, title: title),
      fullscreenDialog: true,
    );
  }

  @override
  State<PaymentWebviewModal> createState() => _PaymentWebviewModalState();
}

class _PaymentWebviewModalState extends State<PaymentWebviewModal> {
  InAppWebViewController? webViewController;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => _confirmCancel(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
              _checkUrlForRedirect(url);
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
              });
              _checkUrlForRedirect(url);
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _checkUrlForRedirect(WebUri? url) {
    if (url == null) return;
    final urlStr = url.toString().toLowerCase();

    // Check common payment gateway success / cancel callbacks
    if (urlStr.contains('/payment/success') ||
        urlStr.contains('status=success') ||
        urlStr.contains('payment_status=completed') ||
        urlStr.contains('ottu/status') && urlStr.contains('paid')) {
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Payment completed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else if (urlStr.contains('/payment/failed') ||
        urlStr.contains('status=failed') ||
        urlStr.contains('payment_status=cancelled')) {
      Get.back(result: false);
      Get.snackbar(
        'Failed',
        'Payment was cancelled or failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmCancel() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel the payment process?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No, Stay'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back(); // close dialog
              Get.back(result: false); // close webview with false
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
