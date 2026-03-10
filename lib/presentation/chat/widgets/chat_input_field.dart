import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSend;

  ChatInputField({required this.onSend});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () {
                // TODO: file picker
              },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                // TODO: voice record
              },
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.green),
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                widget.onSend(controller.text.trim());
                controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}