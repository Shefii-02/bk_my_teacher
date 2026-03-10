class TodayClassModel {
  final int id;
  final String startTime;
  final String endTime;
  final String platform;
  final String time;
  final String subject;
  final String course;
  final String teacherName;
  final String? meetingLink;
  final String? recordedLink;
  final String title;
  final String type;
  final String status;


  TodayClassModel({
    required this.id,
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.platform,
    required this.subject,
    required this.course,
    required this.teacherName,
    required this.meetingLink,
    required this.recordedLink,
    required this.status,
    required this.title,
    required this.type,
  });

  factory TodayClassModel.fromJson(Map<String, dynamic> json) {
    return TodayClassModel(
      id: json['id'],
      time: json['time'],
      subject: json['subject'],
      course: json['course'],
      teacherName: json['teacher_name'],
      meetingLink: json['meeting_link'],
      recordedLink: json['recorded_link'],
      status: json['status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      platform: json['platform'],
      title: json['title'],
      type: json['type'],
    );
  }
}