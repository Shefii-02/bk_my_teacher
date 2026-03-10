import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class ChatHomeScreenDummy extends StatelessWidget {
  const ChatHomeScreenDummy({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              child: Text('This Feature is not available yet'),
            ),
          )
        ],
      ),
    );
  }


}
