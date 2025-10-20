import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  final String guestId;
  const EventsScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context) {
    final events = [
      {"title": "Annual Teacher’s Meet", "date": "Oct 10, 2025"},
      {"title": "Guest Workshop on AI", "date": "Oct 15, 2025"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Events & Workshops")),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(event["title"]!),
              subtitle: Text("Date: ${event["date"]}"),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Registered for ${event["title"]}")),
                  );
                },
                child: const Text("Register"),
              ),
            ),
          );
        },
      ),
    );
  }
}
