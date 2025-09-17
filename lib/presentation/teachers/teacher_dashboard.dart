import 'package:flutter/material.dart';
import '../../services/teacher_api_service.dart';
import 'students_list.dart';
import 'courses_screen.dart';
import 'dashboard_home.dart';
import 'my_class_list.dart';
import 'profile_screen.dart';

class TeacherDashboard extends StatefulWidget {
  final Map<String, dynamic> teacherData;

  const TeacherDashboard({super.key, required this.teacherData});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    print(widget.teacherData);
    //
    final teacherId = widget.teacherData['teacherId'];

    // ✅ Pass teacherData to DashboardHome and ProfileScreen (example)
    _screens = [
      DashboardHome(teacherData: teacherId),
      const StudentsList(),
      const CoursesScreen(),
      const MyClassList(),
      // ProfileScreen(teacherData: teacherId),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Students"),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: "My Class",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
