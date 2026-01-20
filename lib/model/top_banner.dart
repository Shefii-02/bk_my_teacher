class TopBanner {
  final int id;
  final String title;
  final String mainImage;
  final String thumb;
  final String description;
  final int priorityOrder;
  final String bannerType;
  final String ctaLabel;
  final String ctaAction;
  final String type;
  final bool isBooked;
  final String? lastBookedAt;
  final Map<String, dynamic>? typeDetails;


  TopBanner({
    required this.id,
    required this.title,
    required this.mainImage,
    required this.thumb,
    required this.description,
    required this.priorityOrder,
    required this.bannerType,
    required this.ctaLabel,
    required this.ctaAction,
    required this.isBooked,
    required this.type,
    this.lastBookedAt,
    this.typeDetails,

  });

  factory TopBanner.fromJson(Map<String, dynamic> json) {
    return TopBanner(
      id: json['id'],
      title: json['title'] ?? '',
      mainImage: json['main_image'] ?? '',
      thumb: json['thumb'] ?? '',
      description: json['description'] ?? '',
      priorityOrder: json['priority_order'] ?? 0,
      bannerType: json['banner_type'] ?? '',
      ctaLabel: json['cta_label'] ?? '',
      ctaAction: json['cta_action'] ?? '',
      isBooked: json['is_booked'] ?? false,
      lastBookedAt: json['last_booked_at'],
      type: json['type'] ?? '',
      typeDetails: json['type_details'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['type_details'])
          : null,
    );
  }

  Map<String, dynamic> toCourseMap() {
    return typeDetails ?? {};
  }
}
