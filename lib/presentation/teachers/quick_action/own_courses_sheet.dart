import 'package:flutter/material.dart';

class OwnCoursesSheet extends StatefulWidget {
  const OwnCoursesSheet({super.key});

  @override
  State<OwnCoursesSheet> createState() => _OwnCoursesSheetState();
}

class _OwnCoursesSheetState extends State<OwnCoursesSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<Map<String, dynamic>>> courses = {
    "Upcoming": [
      {"title": "Flutter Basics", "date": "Nov 15", "time": "10:00 AM"},
      {"title": "Laravel Advanced", "date": "Nov 18", "time": "2:00 PM"},
    ],
    "Ongoing": [
      {"title": "React Native Live", "date": "Nov 13", "time": "1:00 PM"},
    ],
    "Completed": [
      {"title": "Python for Beginners", "date": "Nov 10", "time": "3:00 PM"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: courses.keys.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "📚 My Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blueAccent,
                tabs: courses.keys.map((e) => Tab(text: e)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: courses.keys.map((tab) {
                    final list = courses[tab]!;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final course = list[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(course['title']),
                            subtitle: Text("${course['date']} | ${course['time']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                _showCourseDetails(context, course);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCourseDetails(BuildContext context, Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(course['title'],
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text("${course['date']} | ${course['time']}"),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Join / View Course"),
            )
          ],
        ),
      ),
    );
  }
}
