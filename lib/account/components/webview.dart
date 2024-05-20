import 'package:flutter/material.dart';
import 'package:secure_alert/utils/custom_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GuideWebView extends StatefulWidget {
  const GuideWebView({super.key});

  @override
  State<GuideWebView> createState() => _GuideWebViewState();
}

class _GuideWebViewState extends State<GuideWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Help Center"),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..loadRequest(Uri.parse(
        'https://drive.google.com/file/d/1oYQXDplp_ejKEa2Zv8bWd2k-fqEPv-x5/view?usp=sharing'));
}
