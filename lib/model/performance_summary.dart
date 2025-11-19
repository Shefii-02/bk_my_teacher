class PerformanceSummary {
  final String watchTime;
  final int students;
  final double avgRating;
  final String growth;
  final int sessions;

  PerformanceSummary({
    required this.watchTime,
    required this.students,
    required this.avgRating,
    required this.growth,
    required this.sessions,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      watchTime: json['watch_time']?.toString() ?? "0",
      students: int.tryParse(json['students'].toString()) ?? 0,
      avgRating: double.tryParse(json['avg_rating'].toString()) ?? 0.0,
      growth: json['growth']?.toString() ?? "0%",
      sessions: int.tryParse(json['sessions'].toString()) ?? 0,
    );
  }
}

class PerformanceChart {
  final List<String> labels;
  final List<num> values;

  PerformanceChart({required this.labels, required this.values});

  factory PerformanceChart.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'];
    final rawValues = json['values'];

    List<String> labels = [];
    List<num> values = [];

    if (rawLabels is List) {
      labels = rawLabels.map((e) => e.toString()).toList();
    } else if (rawLabels is String) {
      labels = rawLabels.split(',');
    }

    if (rawValues is List) {
      values = rawValues.map((e) => num.tryParse(e.toString()) ?? 0).toList();
    } else if (rawValues is String) {
      values = rawValues.split(',').map((e) => num.tryParse(e) ?? 0).toList();
    }

    return PerformanceChart(labels: labels, values: values);
  }
}

class TeacherPerformanceModel {
  final PerformanceSummary summary;
  final PerformanceChart chart;
  final String filter;

  TeacherPerformanceModel({
    required this.summary,
    required this.chart,
    required this.filter,
  });

  factory TeacherPerformanceModel.fromJson(Map<String, dynamic> json) {
    return TeacherPerformanceModel(
      summary: json['summary'] is Map
          ? PerformanceSummary.fromJson(json['summary'])
          : PerformanceSummary.fromJson({}),
      chart: json['chart'] is Map
          ? PerformanceChart.fromJson(json['chart'])
          : PerformanceChart.fromJson({}),
      filter: json['filter']?.toString() ?? "",
    );
  }
}
