import 'dart:convert';
import 'package:BookMyTeacher/presentation/teachers/quick_action/my_schedules_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/launch_status_service.dart';
import '../../services/teacher_api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // Dummy schedule data
  final Map<DateTime, List<Map<String, String>>> _events = {
    DateTime.utc(2025, 11, 10): [
      {"type": "Individual Class", "time": "10:00 AM - 11:00 AM"},
      {"type": "Own Course Class", "time": "2:00 PM - 3:30 PM"},
    ],
    DateTime.utc(2025, 11, 12): [
      {"type": "Webinar", "time": "6:00 PM - 8:00 PM"},
    ],
    DateTime.utc(2025, 11, 15): [
      {"type": "Workshop", "time": "11:00 AM - 1:00 PM"},
    ],
  };

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
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
                height: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                context.push('/teacher-dashboard');
                              },
                            ),
                          ),
                          const Text(
                            "My Schedules",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                          const SizedBox(width: 50),
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
                  child: ListView(
                    children: [
                      // 📆 Calendar
                      TableCalendar(
                        focusedDay: _focusedDay,
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;

                            // Optional: reset selected day when month changes
                            _selectedDay = null;

                            // Optional: load events for the new month if you have a dynamic event source
                            //  _loadEventsForMonth(focusedDay);
                          });
                        },
                        eventLoader: _getEventsForDay,
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🧾 Scheduled Classes List
                      if (_selectedDay == null)
                        const Center(
                          child: Text("Select a date to see your schedule"),
                        ),
                      if (_selectedDay != null)
                        ..._getEventsForDay(_selectedDay!).map((event) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: _buildIcon(event["type"]!),
                              title: Text(event["type"]!),
                              subtitle: Text(event["time"]!),
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  _showClassDetails(context, event);
                                },
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🧩 Helper: event icon by type
  Widget _buildIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case "Individual Class":
        icon = Icons.person;
        color = Colors.blueAccent;
        break;
      case "Own Course Class":
        icon = Icons.school;
        color = Colors.green;
        break;
      case "Webinar":
        icon = Icons.video_call;
        color = Colors.purple;
        break;
      case "Workshop":
        icon = Icons.work;
        color = Colors.orange;
        break;
      default:
        icon = Icons.event;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  // 📋 Show class details in modal
  void _showClassDetails(
    BuildContext context,
    Map<String, String> eventDetails,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventDetails["type"]!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text("Time: ${eventDetails['time']}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 18),
                SizedBox(width: 8),
                Text("Location: Online / Classroom"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.people_outline, size: 18),
                SizedBox(width: 8),
                Text("Students Enrolled: 25"),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.video_camera_front_outlined),
              label: const Text("Join / Manage Class"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
