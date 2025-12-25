// schedules_sheet.dart
import 'dart:collection';
import 'package:BookMyTeacher/services/teacher_api_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../model/schedule_model.dart';
import 'class_details_screen.dart';
import 'course_details_page.dart';

class SchedulesSheet extends StatefulWidget {

  const SchedulesSheet({super.key});

  @override
  State<SchedulesSheet> createState() => _SchedulesSheetState();
}

class _SchedulesSheetState extends State<SchedulesSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = false;
  DateTime _firstDay = DateTime.now();
  DateTime _lastDay = DateTime.now();


  // Map with DateTime.utc(day) keys and list of ScheduleEvent values
  Map<DateTime, List<ScheduleEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadMonthlyEvents(_focusedDay);
  }

  // Convert backend date string keys ("2025-11-10") to DateTime.utc key
  DateTime _toKey(String dateString) {
    final d = DateTime.parse(dateString);
    return DateTime.utc(d.year, d.month, d.day);
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _loadMonthlyEvents(DateTime month) async {
    setState(() => _loading = true);
    final monthStr = "${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}";
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
        _focusedDay = DateTime(month.year, month.month, 1);
      });

    } catch (e) {
      // handle error (toast/snackbar)
      debugPrint('Failed to load schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load schedule: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0x4DFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // balance alignment
                  const Text(
                    "🗓 My Schedules",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 12),

              TableCalendar(
                focusedDay: _focusedDay,
                // firstDay: DateTime.utc(2024, 1, 1),
                // lastDay: DateTime.utc(2030, 12, 31),
                firstDay: _firstDay,
                lastDay: _lastDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                const Center(child: Text("Select a date to see your schedule")),
              const SizedBox(height: 8),

              if (_selectedDay != null) ...[
                if (_getEventsForDay(_selectedDay!).isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.event_busy,
                            size: 42,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "No classes scheduled yet.\nCheck back later.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._getEventsForDay(_selectedDay!).map((event) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: event.thumbnailUrl != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event.thumbnailUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, st) =>
                            const CircleAvatar(child: Icon(Icons.event)),
                          ),
                        )
                            : _buildIcon(event.type),
                        title: Text(event.topic),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${event.timeStart} - ${event.timeEnd} • ${event.subjectName}",
                            ),
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
                                builder: (_) =>
                                    CourseDetailsPage(courseId: event.id),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
      label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: bg,
    );
  }
}
