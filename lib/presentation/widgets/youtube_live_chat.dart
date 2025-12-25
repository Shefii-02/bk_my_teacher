import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeLiveChat extends StatefulWidget {
  final String videoId;

  const YouTubeLiveChat({super.key, required this.videoId});

  @override
  State<YouTubeLiveChat> createState() => _YouTubeLiveChatState();
}

class _YouTubeLiveChatState extends State<YouTubeLiveChat> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final chatUrl =
        'https://www.youtube.com/live_chat?v=${widget.videoId}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(chatUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat View
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: WebViewWidget(controller: _controller),
        ),
      ],
    );
  }
}
