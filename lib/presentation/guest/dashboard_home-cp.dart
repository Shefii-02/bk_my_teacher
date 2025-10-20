import 'package:flutter/material.dart';

class DashboardHome extends StatelessWidget {
  final Future<Map<String, dynamic>> guestDataFuture;
  final String guestId;

  const DashboardHome({
    super.key,
    required this.guestDataFuture,
    required this.guestId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: guestDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No guest data found"));
        }

        final guest = snapshot.data!;
        final guestName = guest['name'] ?? 'Guest';

        // Dummy featured webinars
        final featuredWebinars = [
          {"title": "Learn English Basics", "date": "Sep 28, 2025"},
          {"title": "Intro to Math Tricks", "date": "Oct 1, 2025"},
          {"title": "Science Made Fun", "date": "Oct 5, 2025"},
        ];

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, $guestName!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickActionButton(context, "Free Webinars", Icons.live_tv, () {
                      Navigator.pushNamed(context, '/free-webinars', arguments: guestId);
                    }),
                    _quickActionButton(context, "Explore Teachers", Icons.group, () {
                      Navigator.pushNamed(context, '/explore', arguments: guestId);
                    }),
                    _quickActionButton(context, "My Classes", Icons.video_library, () {
                      Navigator.pushNamed(context, '/my-classes', arguments: guestId);
                    }),
                  ],
                ),
                const SizedBox(height: 30),

                // Featured Webinars
                const Text(
                  "Featured Webinars",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredWebinars.length,
                    itemBuilder: (context, index) {
                      final webinar = featuredWebinars[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 12),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                webinar['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Date: ${webinar['date']}"),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Joined ${webinar['title']}")),
                                  );
                                },
                                child: const Text("Join"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                // Recommended Courses (Example)
                const Text(
                  "Recommended Courses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: List.generate(3, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text("${index + 1}"),
                        ),
                        title: Text("Course ${index + 1}"),
                        subtitle: const Text("Beginner Friendly"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Enrolled in Course ${index + 1}")),
                            );
                          },
                          child: const Text("Enroll"),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
