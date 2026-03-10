import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(message.message);

      case MessageType.image:
        return Image.network(message.fileUrl ?? "");

      case MessageType.pdf:
        return Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red),
            SizedBox(width: 6),
            Text("PDF File"),
          ],
        );

      case MessageType.audio:
        return Row(
          children: [
            Icon(Icons.play_arrow),
            Text("Voice Message"),
          ],
        );
    }
  }
}