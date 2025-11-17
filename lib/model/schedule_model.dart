
class ScheduleResponse {
  final String month; // e.g. "2025-11"
  final DateTime firstDay;
  final DateTime lastDay;
  final Map<String, List<ScheduleEvent>> events; // keyed by "YYYY-MM-DD"

  ScheduleResponse({
    required this.month,
    required this.firstDay,
    required this.lastDay,
    required this.events,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as Map<String, dynamic>? ?? {};
    final Map<String, List<ScheduleEvent>> parsed = {};
    rawEvents.forEach((key, value) {
      parsed[key] = (value as List)
          .map((e) => ScheduleEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });

    return ScheduleResponse(
      month: json['month'] ?? '',
      firstDay: DateTime.tryParse(json['first_day']) ?? DateTime.utc(2024, 1, 1),
      lastDay: DateTime.tryParse(json['last_day']) ?? DateTime.utc(2030, 12, 31),
      events: parsed,
    );
  }

  Map<String, dynamic> toJson() => {
    "month": month,
    "first_day": firstDay,
    "last_day": lastDay,
    "events": events.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
  };
}

class ScheduleEvent {
  final int id;
  final String type;
  final String topic;
  final String description;
  final String? classLink;
  final String? meetingPassword;
  final String hostName;
  final String classStatus; // upcoming / live / completed
  final bool attendanceRequired;
  final String subjectName;
  final String? thumbnailUrl;
  final String classType; // online / offline / hybrid
  final String? location;
  final int? courseId;
  final int? duration; // minutes
  final String timeStart; // "10:00"
  final String timeEnd; // "11:00"
  final int students;
  final String source;

  ScheduleEvent({
    required this.id,
    required this.type,
    required this.topic,
    required this.description,
    this.classLink,
    this.meetingPassword,
    required this.hostName,
    required this.classStatus,
    required this.attendanceRequired,
    required this.subjectName,
    this.thumbnailUrl,
    required this.classType,
    this.location,
    this.courseId,
    this.duration,
    required this.source,
    required this.timeStart,
    required this.timeEnd,
    required this.students,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleEvent(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
      classLink: json['class_link'],
      meetingPassword: json['meeting_password'],
      hostName: json['host_name'] ?? '',
      classStatus: (json['class_status'] ?? 'upcoming'),
      attendanceRequired: json['attendance_required'] == null
          ? false
          : (json['attendance_required'] is bool
          ? json['attendance_required']
          : (json['attendance_required'].toString() == '1' ||
          json['attendance_required'].toString().toLowerCase() == 'true')),
      subjectName: json['subject_name'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      classType: json['class_type'] ?? 'online',
      location: json['location'],
      courseId: json['course_id'] == null ? null : int.tryParse(json['course_id'].toString()),
      duration: json['duration'] == null ? null : int.tryParse(json['duration'].toString()),
      timeStart: json['time_start'] ?? '',
      timeEnd: json['time_end'] ?? '',
      source: json['source'] ?? 'gmeet',
      students: json['students'] == null ? 0 : int.tryParse(json['students'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "topic": topic,
    "description": description,
    "class_link": classLink,
    "meeting_password": meetingPassword,
    "host_name": hostName,
    "class_status": classStatus,
    "attendance_required": attendanceRequired,
    "subject_name": subjectName,
    "thumbnail_url": thumbnailUrl,
    "class_type": classType,
    "location": location,
    "course_id": courseId,
    "duration": duration,
    "time_start": timeStart,
    "time_end": timeEnd,
    "students": students,
    "source": source,
  };

  // Convenience: convert "YYYY-MM-DD" + timeStart into a DateTime (local)
  DateTime startDateFor(String dateString) {
    // dateString expected "YYYY-MM-DD"
    final parts = dateString.split('-');
    if (parts.length < 3) return DateTime.now();
    final y = int.tryParse(parts[0]) ?? DateTime.now().year;
    final m = int.tryParse(parts[1]) ?? DateTime.now().month;
    final d = int.tryParse(parts[2]) ?? DateTime.now().day;
    final timeParts = timeStart.split(':');
    final hh = int.tryParse(timeParts[0]) ?? 0;
    final mm = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    return DateTime(y, m, d, hh, mm);
  }
}
