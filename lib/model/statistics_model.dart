class StatisticsModel {
  final String range;
  final Map<String, SpendDetail> spend;
  final Map<String, SpendDetail> watch;
  final String totalSpend;
  final String totalWatch;

  StatisticsModel({
    required this.totalSpend,
    required this.totalWatch,
    required this.range,
    required this.spend,
    required this.watch,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalSpend: json['summary']['total_spend'] ?? "0",
      totalWatch: json['summary']['total_watch'] ?? "0",
      range: json['range'] ?? "Last 7 Days",
      spend: parseSection(json['spend_time']),
      watch: parseSection(json['watch_time']),
    );
  }
}

class SpendDetail {
  final List<double> individual;
  final List<double> ownCourses;
  final List<double> youtube;
  final List<double> workshops;
  final List<double> webinar;

  SpendDetail({
    required this.individual,
    required this.ownCourses,
    required this.youtube,
    required this.workshops,
    required this.webinar,
  });

  factory SpendDetail.fromJson(Map<String, dynamic> json) {
    return SpendDetail(
      individual: convertList(json['Individual']),
      ownCourses: convertList(json['Own Courses']),
      youtube: convertList(json['YouTube']),
      workshops: convertList(json['Workshops']),
      webinar: convertList(json['Webinar']),
    );
  }
}

/// parse "Last Day", "Last 7 Days", "Current Month", etc
Map<String, SpendDetail> parseSection(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data.map(
          (key, value) =>
          MapEntry(key, SpendDetail.fromJson(value)),
    );
  }
  return {};
}

/// convert [1,2,3] → List<double>
List<double> convertList(dynamic list) {
  if (list is List) {
    return list.map<double>((e) => (e as num).toDouble()).toList();
  }
  return [];
}



// class StatisticsModel {
//   final SpendSection spend;
//   final WatchSection watch;
//
//   StatisticsModel({
//     required this.spend,
//     required this.watch,
//   });
//
//   factory StatisticsModel.fromJson(Map<String, dynamic> json) {
//     return StatisticsModel(
//       spend: SpendSection.fromJson(json['spend_time']),
//       watch: WatchSection.fromJson(json['watch_time']),
//     );
//   }
// }
//
// class SpendSection {
//   final Map<String, List<double>> individual;
//   final Map<String, List<double>> ownCourses;
//   final Map<String, List<double>> youtube;
//   final Map<String, List<double>> workshops;
//   final Map<String, List<double>> webinar;
//
//   SpendSection({
//     required this.individual,
//     required this.ownCourses,
//     required this.youtube,
//     required this.workshops,
//     required this.webinar,
//   });
//
//   factory SpendSection.fromJson(Map<String, dynamic> json) {
//     return SpendSection(
//       individual: convertMap(json['Individual']),
//       ownCourses: convertMap(json['Own Courses']),
//       youtube: convertMap(json['YouTube']),
//       workshops: convertMap(json['Workshops']),
//       webinar: convertMap(json['Webinar']),
//     );
//   }
// }
//
// class WatchSection {
//   final Map<String, List<double>> individual;
//   final Map<String, List<double>> ownCourses;
//   final Map<String, List<double>> youtube;
//   final Map<String, List<double>> workshops;
//   final Map<String, List<double>> webinar;
//
//   WatchSection({
//     required this.individual,
//     required this.ownCourses,
//     required this.youtube,
//     required this.workshops,
//     required this.webinar,
//   });
//
//   factory WatchSection.fromJson(Map<String, dynamic> json) {
//     return WatchSection(
//       individual: convertMap(json['Individual']),
//       ownCourses: convertMap(json['Own Courses']),
//       youtube: convertMap(json['YouTube']),
//       workshops: convertMap(json['Workshops']),
//       webinar: convertMap(json['Webinar']),
//     );
//   }
// }
//
// /// Converts API maps safely into <String, List<double>>
// Map<String, List<double>> convertMap(dynamic data) {
//   if (data is Map) {
//     return data.map(
//           (key, value) => MapEntry(
//         key.toString(),
//         List<double>.from(value.map((e) => (e as num).toDouble())),
//       ),
//     );
//   }
//   return {};
// }
