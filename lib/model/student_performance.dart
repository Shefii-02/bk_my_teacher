
class StudentPerformance {
  final int totalClasses;
  final int attended;
  final int missed;
  final double performancePercentage;
  final List<MonthWisePerformance> monthWise;

  StudentPerformance({
    required this.totalClasses,
    required this.attended,
    required this.missed,
    required this.performancePercentage,
    required this.monthWise,
  });

  factory StudentPerformance.fromJson(Map<String, dynamic> json) {
    return StudentPerformance(
      totalClasses: json["total_classes"] ?? 0,
      attended: json["attended"] ?? 0,
      missed: json["missed"] ?? 0,
      performancePercentage: (json["performance_percentage"] ?? 0).toDouble(),
      monthWise: (json["month_wise"] as List<dynamic>)
          .map((e) => MonthWisePerformance.fromJson(e))
          .toList(),
    );
  }
}

class MonthWisePerformance {
  final String month;
  final int attended;
  final int missed;

  MonthWisePerformance({
    required this.month,
    required this.attended,
    required this.missed,
  });

  factory MonthWisePerformance.fromJson(Map<String, dynamic> json) {
    return MonthWisePerformance(
      month: json["month"] ?? "",
      attended: json["attended"] ?? 0,
      missed: json["missed"] ?? 0,
    );
  }
}