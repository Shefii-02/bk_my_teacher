import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/launch_status_service.dart';
import '../../services/teacher_api_service.dart';
import '../../services/user_check_service.dart';
import 'students_list.dart';
import 'courses_screen.dart';
import 'dashboard_home.dart';
import 'my_class_list.dart';
import 'profile_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final String teacherId;
  const TeacherDashboard({super.key, required this.teacherId});
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>> _teacherDataFuture;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    print(widget.teacherId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _checkUser();
    });
    //
    final teacherId = widget.teacherId;
    // _teacherDataFuture = _fetchTeacherData();
    _teacherDataFuture = TeacherApiService().fetchTeacherData(teacherId);

    // print(_teacherDataFuture);
    // ✅ Pass teacherData to DashboardHome and ProfileScreen (example)
    _screens = [
      DashboardHome(
        teacherDataFuture: _teacherDataFuture,
        teacherId: teacherId,
      ),
      StudentsList(teacherId: teacherId),
      CoursesScreen(teacherId: teacherId),
      MyClassList(teacherId: teacherId),
      ProfileScreen(
        teacherDataFuture: _teacherDataFuture,
        teacherId: teacherId,
      ),
    ];

  }

  // Future<void> _checkUser() async {
  //   final box = Hive.box('app_storage');
  //   final userId = box.get('user_id');
  //   final userRole = box.get('user_role');
  //
  //   if (userId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("User ID not found. Please login again.")),
  //     );
  //     return;
  //   }
  //   final isValid = await UserCheckService().isUserValid(userId,userRole);
  //   if (isValid) {
  //     return;
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("User ID not found. App Rest..")));
  //     await LaunchStatusService.resetApp();
  //     return;
  //   }
  // }

  // Future<Map<String, dynamic>> _fetchTeacherData() async {
  //   final api = TeacherApiService();
  //   return await api.fetchTeacherData(
  //     widget.teacherData['teacherId'],
  //   ); // must return {teacher, steps}
  // }

  @override
  Widget build(BuildContext context) {
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

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("No teacher data found")),
          );
        }

        final teacher = snapshot.data!;
        final stepsData = teacher['steps'] as List<dynamic>;
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
                label: "Students",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: "Courses",
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
