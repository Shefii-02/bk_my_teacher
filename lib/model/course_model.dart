class CourseSummary {
  final List<CourseItem> upcoming_ongoing;
  // final List<CourseItem> ongoing;
  final List<CourseItem> completed;

  CourseSummary({
    required this.upcoming_ongoing,
    // required this.ongoing,
    required this.completed,
  });

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      upcoming_ongoing: (json['upcoming_ongoing'] as List)
          .map((e) => CourseItem.fromJson(e))
          .toList(),
      // ongoing: (json['ongoing'] as List)
      //     .map((e) => CourseItem.fromJson(e))
      //     .toList(),
      completed: (json['completed'] as List)
          .map((e) => CourseItem.fromJson(e))
          .toList(),
    );
  }
}

class CourseItem {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String startDate;
  final String startTime;
  final String endTime;
  final int duration;
  final String type;
  final int totalClasses;
  final int completedClasses;

  CourseItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.type,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalClasses,
    required this.completedClasses,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'],
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      type: json['type'] ?? 'webinar',
      startDate: json['start_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      duration: json['duration'] ?? 0,
      totalClasses: json['total_classes'] ?? 0,
      completedClasses: json['completed_classes'] ?? 0,
    );
  }
}
