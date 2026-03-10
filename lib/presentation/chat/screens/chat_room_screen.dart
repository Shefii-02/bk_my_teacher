import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatRoomScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  ChatRoomScreen({
    required this.courseId,
    required this.courseName,
  });

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final String myId = "1";

  List<MessageModel> messages = [];

  void _sendMessage(String text) {
    final message = MessageModel(
      id: DateTime.now().toString(),
      senderId: myId,
      message: text,
      type: MessageType.text,
      createdAt: DateTime.now(),
    );

    setState(() {
      messages.insert(0, message);
    });

    // TODO: send to backend/socket
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == myId;
                return MessageBubble(message: msg, isMe: isMe);
              },
            ),
          ),
          ChatInputField(onSend: _sendMessage),
        ],
      ),
    );
  }
}