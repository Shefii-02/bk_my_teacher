import 'package:BookMyTeacher/presentation/students/teachers_list.dart';
import 'package:BookMyTeacher/services/student_api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as ref;
import '../../providers/user_provider.dart';
import '../students/dashboard_home.dart';
import '../students/courses_screen.dart';
import '../students/my_class_list.dart';
import '../students/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

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
    _screens = [
      DashboardHome(),
      TeachersList(),
      CoursesScreen(),
      MyClassList(),
      ProfileScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Teachers"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Store"),
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
