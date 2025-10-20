import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/launch_status_service.dart';

class ProfileScreen extends StatefulWidget {
  final Future<Map<String, dynamic>> studentDataFuture;

  final String studentId;  // Strongly type it

  const ProfileScreen({
    super.key,
    required this.studentDataFuture,
    required this.studentId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _studentDataFuture;

  @override
  void initState() {
    super.initState();
    _studentDataFuture = widget.studentDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    // Example local JSON for stats
    const String jsonData = '''
    [
      { "icon": "book_outlined", "count": "12", "title": "Reviews" },
      { "icon": "people_outline", "count": "24", "title": "Rating" },
      { "icon": "video_camera_front_outlined", "count": "5", "title": "Courses" },
      { "icon": "star_border", "count": "18", "title": "Stars" }
    ]
    ''';

    final List<dynamic> gridItems = json.decode(jsonData);

    final Map<String, IconData> iconMap = {
      "book_outlined": Icons.book_outlined,
      "people_outline": Icons.people_outline,
      "video_camera_front_outlined": Icons.video_camera_front_outlined,
      "star_border": Icons.star_border,
      "assignment_outlined": Icons.assignment_outlined,
      "payment_outlined": Icons.payment_outlined,
    };

    Future<void> _logout(BuildContext context) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Logout"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await LaunchStatusService.resetApp();
        context.go('/auth');
      }
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _studentDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("No student data found")),
          );
        }

        final student = snapshot.data!;
        final avatar = student['avatar'] ?? "https://via.placeholder.com/150";
        final name = student['user']['name'] ?? "Unknown student";
        final accountStatus = student['user']['account_status'];
        final userId = student['user']['id'].toString();
        return Scaffold(
          body: Stack(
            children: [
              // Background Image
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background/full-bg.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: [
                  // Top Section
                  SizedBox(
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_left_sharp,
                                    color: Colors.black,
                                  ),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    context.push('/student-dashboard', extra: {'studentId': userId});
                                  },
                                ),
                              ),
                              // Settings button
                              IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.black87,
                                ),
                                onPressed: () async {
                                  final selected = await showMenu<String>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      MediaQuery.of(context).size.width,
                                      80,
                                      0,
                                      0,
                                    ),
                                    items: const [
                                      PopupMenuItem<String>(
                                        value: "logout",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 10),
                                            Text("Logout"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                  if (selected == "logout") _logout(context);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Avatar + Name
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(avatar),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Text(
                              //   "Account Status: $accountStatus",
                              // style: TextStyle(
                              //   color: accountStatus == "Verified"
                              //       ? Colors.green
                              //       : Colors.orange,
                              //   fontWeight: FontWeight.w600,
                              // ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Dynamic grid of cards
                            // GridView.builder(
                            //   shrinkWrap: true,
                            //   physics: const NeverScrollableScrollPhysics(),
                            //   itemCount: gridItems.length,
                            //   gridDelegate:
                            //   const SliverGridDelegateWithFixedCrossAxisCount(
                            //     crossAxisCount: 2,
                            //     crossAxisSpacing: 16,
                            //     mainAxisSpacing: 16,
                            //     childAspectRatio: 1.5,
                            //   ),
                            //   itemBuilder: (context, index) {
                            //     final item = gridItems[index];
                            //     final iconKey = item['icon'];
                            //     final icon = iconMap[iconKey] ?? Icons.help_outline;
                            //     final count = item['count'] ?? "-";
                            //     final title = item['title'] ?? "";
                            //
                            //     return Card(
                            //       elevation: 10,
                            //       shadowColor: Colors.blueAccent.withOpacity(0.3),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(20),
                            //       ),
                            //       child: Container(
                            //         padding: const EdgeInsets.all(16),
                            //         decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(20),
                            //           color: Colors.white,
                            //         ),
                            //         child: Row(
                            //           crossAxisAlignment:
                            //           CrossAxisAlignment.center,
                            //           children: [
                            //             CircleAvatar(
                            //               radius: 25,
                            //               backgroundColor:
                            //               Colors.blueAccent.withOpacity(0.1),
                            //               child: Icon(icon, color: Colors.black),
                            //             ),
                            //             const SizedBox(width: 16),
                            //             Column(
                            //               mainAxisAlignment:
                            //               MainAxisAlignment.center,
                            //               crossAxisAlignment:
                            //               CrossAxisAlignment.start,
                            //               children: [
                            //                 Text(
                            //                   count,
                            //                   style: const TextStyle(
                            //                     fontSize: 22,
                            //                     fontWeight: FontWeight.bold,
                            //                     color: Colors.black,
                            //                   ),
                            //                 ),
                            //                 Text(
                            //                   title,
                            //                   style: const TextStyle(
                            //                     fontSize: 14,
                            //                     fontWeight: FontWeight.w500,
                            //                     color: Colors.black87,
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            const SizedBox(height: 20),
                            // Placeholder for future content
                            Card(
                              elevation: 5,
                              shadowColor: Colors.grey.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Your account is ${student['user']['account_status']}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
