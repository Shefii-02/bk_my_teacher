import 'package:flutter/material.dart';

class FreeWebinarsScreen extends StatelessWidget {
  final String guestId;
  const FreeWebinarsScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context) {
    final webinars = [
      {"title": "Learn English Basics", "date": "Sep 28, 2025"},
      {"title": "Intro to Math Tricks", "date": "Oct 1, 2025"},
      {"title": "Science Made Fun", "date": "Oct 5, 2025"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Free Webinars")),
      body: ListView.builder(
        itemCount: webinars.length,
        itemBuilder: (context, index) {
          final webinar = webinars[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(webinar["title"]!),
              subtitle: Text("Date: ${webinar["date"]}"),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Joined ${webinar["title"]}!")),
                  );
                },
                child: const Text("Join"),
              ),
            ),
          );
        },
      ),
    );
  }
}
