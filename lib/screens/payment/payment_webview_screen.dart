import 'package:flutter/material.dart';
import 'package:homy/utils/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String authorizationUrl;
  final Function(bool success) onComplete;

  const PaymentWebViewScreen({
    Key? key,
    required this.authorizationUrl,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          if (!_isDisposed && mounted) {
            setState(() => _isLoading = true);
          }
        },
        onPageFinished: (String url) {
          if (!_isDisposed && mounted) {
            setState(() => _isLoading = false);
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains(Constants.paymentPaidUrl)) {
            _handlePaymentComplete(true);
            return NavigationDecision.prevent;
          }
          
          if (request.url.contains(Constants.paymentCancelUrl)) {
            _handlePaymentComplete(false);
            return NavigationDecision.prevent;
          }
          
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _handlePaymentComplete(bool success) {
    if (_isDisposed || !mounted) return;
    
    widget.onComplete(success);
    Get.back(result: success);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handlePaymentComplete(false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handlePaymentComplete(false),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white70,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 