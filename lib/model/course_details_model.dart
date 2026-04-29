class CourseDetails {
  final CourseInfo course;
  final ClassGroups classes;
  final List<MaterialItem> materials;

  CourseDetails({
    required this.course,
    required this.classes,
    required this.materials,
  });

  factory CourseDetails.fromJson(Map<String, dynamic> json) {
    return CourseDetails(
      course: CourseInfo.fromJson(json['course']),
      classes: ClassGroups.fromJson(json['classes']),
      materials: (json['materials'] as List)
          .map((e) => MaterialItem.fromJson(e))
          .toList(),
    );
  }
}

class CourseInfo {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String? description;
  final String? duration;
  final int totalClasses;
  final int completedClasses;
  final String? mode;
  final String? typeClass;
  final String? price;
  final String? actualPrice;
  final String? courseType;
  final List instructors;
  final String? startedAt;
  final String? endedAt;
  final bool careerGuidance;
  final bool counsellingSection;
  final String? level;
  final String? language;
  final String? category;
  final bool has_review;

  CourseInfo({
    required this.mode,
    required this.typeClass,
    required this.price,
    required this.actualPrice,
    required this.courseType,
    required this.instructors,
    required this.startedAt,
    required this.endedAt,
    required this.careerGuidance,
    required this.counsellingSection,
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.description,
    required this.duration,
    required this.level,
    required this.language,
    required this.category,
    required this.totalClasses,
    required this.completedClasses,
    required this.has_review,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      level: json['level'] ?? '',
      language: json['language'] ?? '',
      category: json['category'] ?? '',
      totalClasses: json['total_classes'] ?? '',
      completedClasses: json['completed_classes'] ?? '',
      mode: json['mode'] ?? '',
      typeClass: json['type_class'] ?? '',
      actualPrice: json['actual_price'] ?? '',
      price: json['price'] ?? '',
      courseType: json['course_type'] ?? '',
      instructors: json['instructors'] ?? [],
      startedAt: json['started_at'] ?? '',
      endedAt: json['ended_at'] ?? '',
      careerGuidance: json['career_guidance'] ?? false,
      counsellingSection: json['counselling_section'] ?? false,
      has_review: json['has_review'] ?? false,
    );
  }
}

class ClassGroups {
  final List<ClassItem> ongoing_upcoming;
  final List<ClassItem> completed;

  ClassGroups({required this.ongoing_upcoming, required this.completed});

  factory ClassGroups.fromJson(Map<String, dynamic> json) {
    return ClassGroups(
      ongoing_upcoming: (json['ongoing_upcoming'] as List)
          .map((e) => ClassItem.fromJson(e))
          .toList(),
      completed: (json['completed'] as List)
          .map((e) => ClassItem.fromJson(e))
          .toList(),
    );
  }
}

class ClassItem {
  final String id;
  final String title;
  final String date;
  final String timeStart;
  final String timeEnd;
  final String classStatus;
  final String source;
  final String? joinLink;
  final String? recordedVideo;
  final bool attendanceTaken;
  final int totalStudents;
  final int presentCount;
  final String actualDuration;
  final String actualStarted;
  final String actualEnded;
  final String notes;

  ClassItem({
    required this.id,
    required this.title,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.classStatus,
    required this.attendanceTaken,
    required this.source,
    required this.joinLink,
    required this.recordedVideo,
    required this.totalStudents,
    required this.presentCount,
    required this.actualDuration,
    required this.actualStarted,
    required this.actualEnded,
    required this.notes
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date_time'] ?? '',
      timeStart: json['start_date_time'] ?? '',
      timeEnd: json['end_date_time'] ?? '',
      classStatus: json['status'] ?? '',
      source: json['source'] ?? '',
      joinLink: json['join_link'] ?? '',
      recordedVideo: json['recorded_video'] ?? '',
      attendanceTaken:
          json['attendance_taken'] == true || json['attendance_taken'] == 1,

      totalStudents: json['total_students'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      actualDuration: json['actual_duration'] ?? '',
      actualStarted: json['actual_started'] ?? '',
      actualEnded: json['actual_ended'],
      notes: json['notes'],
    );
  }
}

class MaterialItem {
  final int id;
  final String title;
  final String fileUrl;
  final String fileType;

  MaterialItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.fileType,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileType: json['file_type'] ?? '',
    );
  }
}
