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
  final String description;
  final String duration;
  final String level;
  final String language;
  final String category;
  final int totalClasses;
  final int completedClasses;

  CourseInfo({
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
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
      duration: json['duration'],
      level: json['level'],
      language: json['language'],
      category: json['category'],
      totalClasses: json['total_classes'],
      completedClasses: json['completed_classes'],
    );
  }
}

class ClassGroups {
  final List<ClassItem> upcoming;
  final List<ClassItem> ongoing;
  final List<ClassItem> completed;

  ClassGroups({
    required this.upcoming,
    required this.ongoing,
    required this.completed,
  });

  factory ClassGroups.fromJson(Map<String, dynamic> json) {
    return ClassGroups(
      upcoming:
      (json['upcoming'] as List).map((e) => ClassItem.fromJson(e)).toList(),
      ongoing:
      (json['ongoing'] as List).map((e) => ClassItem.fromJson(e)).toList(),
      completed: (json['completed'] as List)
          .map((e) => ClassItem.fromJson(e))
          .toList(),
    );
  }
}

class ClassItem {
  final int id;
  final String title;
  final String date;
  final String timeStart;
  final String timeEnd;
  final String classStatus;

  ClassItem({
    required this.id,
    required this.title,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.classStatus,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      timeStart: json['time_start'],
      timeEnd: json['time_end'],
      classStatus: json['class_status'],
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
      id: json['id'],
      title: json['title'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
    );
  }
}
