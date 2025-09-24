import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  final String guestId;
  const ExploreScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      {"title": "Top Math Teacher", "desc": "100+ students, 4.9⭐"},
      {"title": "Spoken English Course", "desc": "Beginner Friendly"},
      {"title": "Science Crash Course", "desc": "Interactive Learning"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Explore")),
      body: ListView.builder(
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(rec["title"]!),
              subtitle: Text(rec["desc"]!),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Explored ${rec["title"]}")),
                  );
                },
                child: const Text("Explore"),
              ),
            ),
          );
        },
      ),
    );
  }
}
