import 'package:BookMyTeacher/presentation/teachers/quick_action/class_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/schedule_model.dart';
import '../../services/teacher_api_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = false;

  DateTime _firstDay = DateTime.now();
  DateTime _lastDay = DateTime.now();

  Map<DateTime, List<ScheduleEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadMonthlyEvents(_focusedDay);
  }

  DateTime _toKey(String dateString) {
    final d = DateTime.parse(dateString);
    return DateTime.utc(d.year, d.month, d.day);
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _loadMonthlyEvents(DateTime month) async {
    setState(() => _loading = true);

    try {
      final resp = await TeacherApiService().fetchTeacherSchedule();

      final Map<DateTime, List<ScheduleEvent>> newEvents = {};
      resp.events.forEach((dateStr, list) {
        final key = _toKey(dateStr);
        newEvents[key] = list;
      });

      setState(() {
        _events = newEvents;
        _firstDay = resp.firstDay;
        _lastDay = resp.lastDay;
      });
    } catch (e) {
      debugPrint('Failed to load schedule: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load schedule: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

              /// CONTENT
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
                  child: Column(
                    children: [
                      TableCalendar(
                        focusedDay: _focusedDay,
                        firstDay: _firstDay,
                        lastDay: _lastDay,
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
                            _selectedDay = null;
                          });
                          _loadMonthlyEvents(focusedDay);
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

                      if (_loading)
                        const Center(child: CircularProgressIndicator()),

                      if (!_loading && _selectedDay == null)
                        const Center(
                          child: Text("Select a date to see your schedule"),
                        ),

                      const SizedBox(height: 8),

                      /// EVENT LIST
                      if (_selectedDay != null)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 20),
                            children: _getEventsForDay(_selectedDay!).map((event) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  leading: event.thumbnailUrl != null
                                      ? ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    child: Image.network(
                                      event.thumbnailUrl!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, st) =>
                                      const CircleAvatar(
                                        child: Icon(Icons.event),
                                      ),
                                    ),
                                  )
                                      : _buildIcon(event.type),
                                  title: Text(event.topic),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${event.timeStart} - ${event.timeEnd} • ${event.subjectName}"),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      _statusChip(event.classStatus),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ClassDetailsScreen(
                                            event: event,
                                            dateKey: DateTime.utc(
                                              _selectedDay!.year,
                                              _selectedDay!.month,
                                              _selectedDay!.day,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
      backgroundColor: color.withOpacity(0.15),
      child: Icon(icon, color: color),
    );
  }

  Widget _statusChip(String status) {
    Color bg;

    switch (status) {
      case 'live':
        bg = Colors.redAccent;
        break;
      case 'completed':
        bg = Colors.grey;
        break;
      default:
        bg = Colors.green;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: bg,
    );
  }
}
