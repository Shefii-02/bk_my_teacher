class TimeCardModel {
  final String title;
  final String icon;
  final String time;

  TimeCardModel({
    required this.title,
    required this.icon,
    required this.time,
  });

  factory TimeCardModel.fromJson(Map<String, dynamic> json) {
    return TimeCardModel(
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      time: json['time'] ?? '0 hr',
    );
  }
}
