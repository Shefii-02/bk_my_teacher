import 'dart:ui';

class TaskItem {
  final int id;
  final String title;
  final String description;
  final String taskDate;
  final String endDate;
  final String status;       // 'active' | 'disabled'
  final bool verified;
  final int totalStudents;
  final int completedCount;
  final List<TaskStudent> students;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.taskDate,
    required this.endDate,
    required this.status,
    required this.verified,
    required this.totalStudents,
    required this.completedCount,
    required this.students,
  });

  factory TaskItem.fromJson(Map<String, dynamic> j) => TaskItem(
    id: j['id'],
    title: j['title'],
    description: j['description'] ?? '',
    taskDate: j['task_date'],
    endDate: j['end_date'],
    status: j['status'],
    verified: j['verified'] ?? false,
    totalStudents: j['total_students'],
    completedCount: j['completed_count'],
    students: (j['students'] as List? ?? [])
        .map((s) => TaskStudent.fromJson(s))
        .toList(),
  );
}

class TaskStudent {
  final int id;
  final String name;
  final String initials;
  final Color avatarColor;
  final bool completed;
  final String? completedAt;

  TaskStudent({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.completed,
    this.completedAt,
  });

  factory TaskStudent.fromJson(Map<String, dynamic> j) => TaskStudent(
    id: j['id'],
    name: j['name'],
    initials: j['initials'] ?? '',
    avatarColor: _colorFromHex(j['avatar_color'] ?? '#4A47B0'),
    completed: j['completed'] ?? false,
    completedAt: j['completed_at'],
  );

  static Color _colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}