import 'package:BookMyTeacher/presentation/teachers/quick_action/statistics_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/schedule_page.dart';
import 'package:BookMyTeacher/presentation/teachers/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../providers/user_provider.dart';
import '../widgets/verify_account_popup.dart';
import 'teacher_courses_screen.dart';
import 'dashboard_home.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _initialize();
    _screens = [
      DashboardHome(),
      SchedulePage(),
      TeacherCoursesScreen(),
      StatisticsPage(),
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
    final teacherAsync = ref.watch(userProvider);
    return teacherAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text("Error: $error"))),
      data: (teacher) {
        if (teacher == null) {
          return const Scaffold(
            body: Center(child: Text("No teacher data found")),
          );
        }

        // Convert teacher model to JSON map for easy use
        final teacherData = teacher.toJson();


        print("------------");
        print(teacherData);
        print("------------");

        // If email not verified → show popup
        if (teacherData['email_verified_at'] == null ||
            teacherData['email_verified_at'] == '') {
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
                icon: Icon(Icons.calendar_month),
                label: "Schedule",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: "Store",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: "Statistics",
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
