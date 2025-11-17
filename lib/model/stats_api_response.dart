class LineChartCategory {
  final List<double> individual;
  final List<double> ownCourses;
  final List<double> youtube;
  final List<double> workshops;
  final List<double> webinar;

  LineChartCategory({
    required this.individual,
    required this.ownCourses,
    required this.youtube,
    required this.workshops,
    required this.webinar,
  });

  factory LineChartCategory.fromJson(Map<String, dynamic> json) {
    return LineChartCategory(
      individual: List<double>.from(json["Individual"].map((e) => (e as num).toDouble())),
      ownCourses: List<double>.from(json["Own Courses"].map((e) => (e as num).toDouble())),
      youtube: List<double>.from(json["YouTube"].map((e) => (e as num).toDouble())),
      workshops: List<double>.from(json["Workshops"].map((e) => (e as num).toDouble())),
      webinar: List<double>.from(json["Webinar"].map((e) => (e as num).toDouble())),
    );
  }
}

class StatisticsModel {
  final Map<String, LineChartCategory> spend;
  final Map<String, LineChartCategory> watch;

  StatisticsModel({
    required this.spend,
    required this.watch,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      spend: (json["spend_time"] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, LineChartCategory.fromJson(value)),
      ),
      watch: (json["watch_time"] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, LineChartCategory.fromJson(value)),
      ),
    );
  }
}
