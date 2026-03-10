import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> courses = [
    {"id": "1", "name": "Math Course", "unread": 3},
    {"id": "2", "name": "Science Course", "unread": 0},
  ];

  ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(course["name"][0])),
                  title: Text(course["name"]),
                  trailing: course["unread"] > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.green,
                          child: Text(
                            "${course["unread"]}",
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          courseId: course["id"],
                          courseName: course["name"],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search courses...",
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
