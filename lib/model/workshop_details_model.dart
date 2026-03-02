class WorkshopDetailsModel {
  final WorkshopCourseInfo workshop;
  final WorkshopClassGroups classes;
  final List<WorkshopMaterialItem> materials;

  WorkshopDetailsModel({
    required this.workshop,
    required this.classes,
    required this.materials,
  });

  factory WorkshopDetailsModel.fromJson(Map<String, dynamic> json) {
    return WorkshopDetailsModel(
      workshop: WorkshopCourseInfo.fromJson(json['course']),
      classes: WorkshopClassGroups.fromJson(json['classes']),
      materials: (json['materials'] as List)
          .map((e) => WorkshopMaterialItem.fromJson(e))
          .toList(),
    );
  }
}

class WorkshopCourseInfo {
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

  WorkshopCourseInfo({
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

  factory WorkshopCourseInfo.fromJson(Map<String, dynamic> json) {
    return WorkshopCourseInfo(
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

class WorkshopClassGroups {
  final List<WorkshopClassItem> ongoing_upcoming;
  final List<WorkshopClassItem> completed;

  WorkshopClassGroups({
    required this.ongoing_upcoming,
    required this.completed,
  });

  factory WorkshopClassGroups.fromJson(Map<String, dynamic> json) {
    return WorkshopClassGroups(
      ongoing_upcoming:
      (json['ongoing_upcoming'] as List).map((e) => WorkshopClassItem.fromJson(e)).toList(),
      completed: (json['completed'] as List)
          .map((e) => WorkshopClassItem.fromJson(e))
          .toList(),
    );
  }
}

class WorkshopClassItem {
  final int id;
  final String title;
  final String date;
  final String timeStart;
  final String timeEnd;
  final String classStatus;
  final String source;
  final String? joinLink;
  final String? recordedVideo;


  WorkshopClassItem({
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

  factory WorkshopClassItem.fromJson(Map<String, dynamic> json) {
    return WorkshopClassItem(
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

class WorkshopMaterialItem {
  final int id;
  final String title;
  final String fileUrl;
  final String fileType;

  WorkshopMaterialItem({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.fileType,
  });

  factory WorkshopMaterialItem.fromJson(Map<String, dynamic> json) {
    return WorkshopMaterialItem(
      id: json['id'],
      title: json['title'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
    );
  }
}
