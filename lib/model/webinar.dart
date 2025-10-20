class Webinar {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? thumbnailUrl;
  final String? mainImageUrl;
  final bool isRegistered;
  final int registrationsCount;
  final bool canJoin;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? registerEndAt;

  Webinar({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.thumbnailUrl,
    this.mainImageUrl,
    required this.isRegistered,
    required this.registrationsCount,
    required this.canJoin,
    this.startAt,
    this.endAt,
    this.registerEndAt,
  });

  factory Webinar.fromJson(Map<String, dynamic> json) {
    return Webinar(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled Webinar',
      description: json['description'] ?? '',
      status: json['status'] ?? 'unknown',
      thumbnailUrl: json['thumbnail'] ?? json['thumbnail_url'],
      mainImageUrl: json['main_image'] ?? json['main_image_url'],
      isRegistered: json['is_registered'] ?? false,
      registrationsCount: json['registrations_count'] ?? 0,
      canJoin: json['is_registered'] == 'true' ? false : true,
      startAt: json['start_at'] != null
          ? DateTime.parse(json['start_at'])
          : null,
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'])
          : null,
      registerEndAt: json['register_end_at'] != null
          ? DateTime.parse(json['register_end_at'])
          : null,
    );
  }
}
