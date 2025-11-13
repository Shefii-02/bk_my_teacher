import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../services/launch_status_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Future<Map<String, dynamic>> _teacherDataFuture;

  @override
  void initState() {
    super.initState();

    // ✅ Load teacher data from userProvider safely
    _teacherDataFuture = _loadTeacherData();
  }

  Future<Map<String, dynamic>> _loadTeacherData() async {
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;

    if (user == null) {
      // If user data not loaded yet, fetch it silently
      await ref.read(userProvider.notifier).loadUser(silent: true);
      final refreshed = ref.read(userProvider).value;
      if (refreshed == null) throw Exception("Failed to load user data");
      return refreshed.toJson();
    }

    return user.toJson();
  }

  @override
  Widget build(BuildContext context) {
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
        if (context.mounted) context.go('/auth');
      }
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _teacherDataFuture,
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

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("No teacher data found")),
          );
        }

        final teacher = snapshot.data!;
        final avatar = teacher['avatar'] ?? "https://via.placeholder.com/150";
        final user = teacher['user'] ?? {};
        final name = user['name'] ?? "Unknown Teacher";
        final accountStatus = user['account_status'] ?? "Pending";
        final userId = user['id']?.toString() ?? "0";

        return Scaffold(
          body: Stack(
            children: [
              // Background
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background/full-bg.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: [
                  // Header
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
                                  icon: const Icon(Icons.keyboard_arrow_left_sharp,
                                      color: Colors.black),
                                  onPressed: () {
                                    context.go('/teacher-dashboard');
                                  },
                                ),
                              ),
                              // Settings
                              IconButton(
                                icon: const Icon(Icons.settings_outlined,
                                    color: Colors.black87),
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
                                            Icon(Icons.logout, color: Colors.red),
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
                                  fontSize: 22,
                                ),
                              ),
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                            const SizedBox(height: 20),
                            Card(
                              elevation: 5,
                              shadowColor: Colors.grey.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  "Your account is $accountStatus",
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
