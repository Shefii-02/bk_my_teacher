import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/guest_api_service.dart';
import '../../services/launch_status_service.dart';
import '../../services/user_check_service.dart';

// Screens
import 'dashboard_home.dart';
import 'events_screen.dart';
import 'free_webinars_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class GuestDashboard extends StatefulWidget {
  final String guestId;

  const GuestDashboard({super.key, required this.guestId});

  @override
  State<GuestDashboard> createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>> _guestDataFuture;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _checkUser();
    });

    final guestId = widget.guestId.toString();
    _guestDataFuture = GuestApiService().fetchGuestData(guestId);

    _screens = [
      DashboardHome(guestDataFuture: _guestDataFuture, guestId: guestId),
      EventsScreen(guestId: guestId),
      FreeWebinarsScreen(guestId: guestId),
      ExploreScreen(guestId: guestId),
      ProfileScreen(guestDataFuture: _guestDataFuture, guestId: guestId),
    ];
  }

  // Future<void> _checkUser() async {
  //   final box = Hive.box('app_storage');
  //   final userId = box.get('user_id');
  //   final userRole = box.get('user_role');
  //
  //   if (userId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("User ID not found. Please login again.")),
  //     );
  //     return;
  //   }
  //
  //   final isValid = await UserCheckService().isUserValid(userId, userRole);
  //   if (!isValid) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Session expired. Resetting app...")),
  //     );
  //     await LaunchStatusService.resetApp();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _guestDataFuture,
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
            body: Center(child: Text("No guest data found")),
          );
        }

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
              BottomNavigationBarItem(icon: Icon(Icons.video_call), label: "Webinars"),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}
