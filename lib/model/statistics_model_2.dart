class StatisticsModel {
  final String range;
  final SpendOrWatch spend;
  final SpendOrWatch watch;
  final Summary summary;

  StatisticsModel({
    required this.range,
    required this.spend,
    required this.watch,
    required this.summary,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      range: json["range"],
      spend: SpendOrWatch.fromJson(json["spend_time"]),
      watch: SpendOrWatch.fromJson(json["watch_time"]),
      summary: Summary.fromJson(json["summary"]),
    );
  }
}

class SpendOrWatch {
  final Map<String, List<int>> categories;

  SpendOrWatch({required this.categories});

  factory SpendOrWatch.fromJson(Map<String, dynamic> json) {
    return SpendOrWatch(
      categories: json.map(
            (key, value) => MapEntry(key, List<int>.from(value)),
      ),
    );
  }
}

class Summary {
  final String totalSpend;
  final String totalWatch;

  Summary({required this.totalSpend, required this.totalWatch});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalSpend: json["total_spend"],
      totalWatch: json["total_watch"],
    );
  }
}
