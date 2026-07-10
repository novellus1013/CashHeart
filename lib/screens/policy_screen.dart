import 'package:cash_heart/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyScreen extends StatefulWidget {
  final String type;

  const PolicyScreen({super.key, required this.type});

  static const Map<String, String> _urls = {
    'privacy': 'https://cashheart.novelus.dev/privacy',
    'terms': 'https://cashheart.novelus.dev/terms',
  };

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(PolicyScreen._urls[widget.type]!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'privacy' ? '개인정보처리방침' : '이용약관',
        ),
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_hasError)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size28),
                child: Text(
                  '문서를 불러올 수 없습니다. 인터넷 연결을 확인해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: Sizes.size16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
