class WebinarDetailsModel {
  final WebinarCourseInfo course;
  final WebinarClassGroups classes;
  final List<WebinarMaterialItem> materials;

  WebinarDetailsModel({
    required this.course,
    required this.classes,
    required this.materials,
  });

  factory WebinarDetailsModel.fromJson(Map<String, dynamic> json) {
    return WebinarDetailsModel(
      course: WebinarCourseInfo.fromJson(json['course']),
      classes: WebinarClassGroups.fromJson(json['classes']),
      materials: (json['materials'] as List)
          .map((e) => WebinarMaterialItem.fromJson(e))
          .toList(),
    );
  }
}

class WebinarCourseInfo {
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

  WebinarCourseInfo({
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

  factory WebinarCourseInfo.fromJson(Map<String, dynamic> json) {
    return WebinarCourseInfo(
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

class WebinarClassGroups {
  final List<WebinarClassItem> ongoing_upcoming;
  final List<WebinarClassItem> completed;

  WebinarClassGroups({
    required this.ongoing_upcoming,
    required this.completed,
  });

  factory WebinarClassGroups.fromJson(Map<String, dynamic> json) {
    return WebinarClassGroups(
      ongoing_upcoming:
      (json['ongoing_upcoming'] as List).map((e) => WebinarClassItem.fromJson(e)).toList(),
      completed: (json['completed'] as List)
          .map((e) => WebinarClassItem.fromJson(e))
          .toList(),
    );
  }
}

class WebinarClassItem {
  final int id;
  final String title;
  final String date;
  final String timeStart;
  final String timeEnd;
  final String classStatus;
  final String source;
  final String? joinLink;
  final String? recordedVideo;


  WebinarClassItem({
    required this.id,
    required this.title,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.classStatus,
    required this.source,
    required this.joinLink,
    required this.recordedVideo,
  });

  factory WebinarClassItem.fromJson(Map<String, dynamic> json) {
    return WebinarClassItem(
      id: json['id'],
      title: json['title'],
      date: json['date_time'],
      timeStart: json['start_date_time'],
      timeEnd: json['end_date_time'],
      classStatus: json['status'],
        source: json['source'],
        joinLink: json['join_link'],
        recordedVideo: json['recorded_video'],
    );
  }
}

class WebinarMaterialItem {
  final int id;
  final String title;
  final String fileUrl;
  final String fileType;

  WebinarMaterialItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.fileType,
  });

  factory WebinarMaterialItem.fromJson(Map<String, dynamic> json) {
    return WebinarMaterialItem(
      id: json['id'],
      title: json['title'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
    );
  }
}
