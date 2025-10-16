import 'package:flutter/material.dart';

class WebinarStreamPage extends StatelessWidget {
  final Map<String, dynamic> streamData;
  const WebinarStreamPage({super.key, required this.streamData});

  @override
  Widget build(BuildContext context) {
    final provider = streamData['provider'];
    final liveId = streamData['live_id'] ?? '';
    final creds = streamData['credentials'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text("Live - $provider"),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Text(
          "Stream: $liveId\nAppID: ${creds['app_id']}\nSign: ${creds['app_sign']}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
