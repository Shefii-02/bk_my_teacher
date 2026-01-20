import 'package:BookMyTeacher/presentation/students/my_class_list.dart';
import 'package:BookMyTeacher/presentation/students/teachers_list.dart';
import 'package:BookMyTeacher/services/student_api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../providers/user_provider.dart';
import '../students/dashboard_home.dart';
import '../students/courses_screen.dart';
import '../students/my_class_list_1.dart';
import '../students/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/verify_account_popup.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    requestPermissions();
    _initialize();

    _screens = [
      DashboardHome(),
      TeachersList(),
      CoursesScreen(),
      MyClassList(),
      ProfileScreen(),
    ];
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
    } catch (e) {
      print("Google Sign-In init failed: $e");
    }
  }

  Future<void> requestPermissions() async {
    // Permission.camera, Permission.microphone, Permission.contacts,
    await [Permission.manageExternalStorage, Permission.storage].request();
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(userProvider);
    return studentAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text("Error: $error"))),
      data: (student) {
        if (student == null) {
          return const Scaffold(
            body: Center(child: Text("No student data found")),
          );
        }

        // Convert student model to JSON map for easy use
        final studentData = student.toJson();

        // If email not verified → show popup
        if (studentData['email_verified_at'] == null ||
            studentData['email_verified_at'] == '') {
          return VerifyAccountPopup(
            onVerified: () async {
              await ref.read(userProvider.notifier).loadUser();
            },
          );
        }
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: "Teachers",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: "Store",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_library),
                label: "My Class",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }
}
