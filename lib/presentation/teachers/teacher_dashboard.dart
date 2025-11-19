import 'package:BookMyTeacher/presentation/teachers/quick_action/statistics_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/schedule_page.dart';
import 'package:BookMyTeacher/presentation/teachers/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../providers/user_provider.dart';
import '../../services/launch_status_service.dart';
import '../../services/teacher_api_service.dart';
import '../../services/user_check_service.dart';
import 'students_list.dart';
import 'courses_screen.dart';
import 'dashboard_home.dart';
import 'my_class_list.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    _screens = [
      DashboardHome(),
      SchedulePage(),
      CoursesScreen(),
      StatisticsPage(),
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

  }
}
