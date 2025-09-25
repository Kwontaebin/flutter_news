import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({required this.url, super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  double _progress = 0; // 로딩 진행률 (0.0 ~ 1.0)

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return; // State가 트리에 없으면 무시
            setState(() {
              _progress = progress / 100;
            });
          },

          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {
              _progress = 1;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("뉴스 페이지", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: _progress < 1.0
              ? LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey[200], color: Colors.blue, minHeight: 3)
              : const SizedBox.shrink(), // 완료되면 숨김
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
