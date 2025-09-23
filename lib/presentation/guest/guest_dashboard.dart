import 'package:BookMyTeacher/presentation/students/teachers_list.dart';
import 'package:BookMyTeacher/services/student_api_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/launch_status_service.dart';
import '../../services/teacher_api_service.dart';
import '../../services/user_check_service.dart';
import '../students/dashboard_home.dart';
import '../students/courses_screen.dart';
import '../students/my_class_list.dart';
import '../students/profile_screen.dart';
import '../students/teachers_list.dart';

class GuestDashboard extends StatefulWidget {
  final String guestId;

  const GuestDashboard({super.key, required this.guestId});

  @override
  State<GuestDashboard> createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>> _studentDataFuture;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    print("***");
    print(widget.guestId);
    print("***");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUser();
    });
    //
    final studentId = widget.guestId.toString();
    // _studentDataFuture = _fetchstudentData();
    _studentDataFuture = StudentApiService().fetchStudentData(studentId);

    // print(_studentDataFuture);
    // ✅ Pass studentData to DashboardHome and ProfileScreen (example)
    _screens = [
      DashboardHome(
        studentDataFuture: _studentDataFuture,
        studentId: studentId,
      ),
      TeachersList(studentId: studentId),
      CoursesScreen(studentId: studentId),
      MyClassList(studentId: studentId),
      ProfileScreen(
        studentDataFuture: _studentDataFuture,
        studentId: studentId,
      ),
    ];

  }

  // Future<Map<String, dynamic>> _fetchstudentData() async {
  //   final api = TeacherApiService();
  //   return await api.fetchstudentData(
  //     widget.studentData['studentId'],
  //   ); // must return {teacher, steps}
  // }

  Future<void> _checkUser() async {
    final box = Hive.box('app_storage');
    final userId = box.get('user_id');
    final userRole = box.get('user_role');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID not found. Please login again.")),
      );
      return;
    }

    final isValid = await UserCheckService().isUserValid(userId,userRole);
    print(")))))))");
    print(isValid);
    if (isValid) {
      return;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User ID not found. App Rest..")));
      await LaunchStatusService.resetApp();
      return;
    }
  }


  @override
  Widget build(BuildContext context) {
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
            body: Center(child: Text("No Student data found")),
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home"
              ),
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
