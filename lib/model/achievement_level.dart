class AchievementResponse {
  final List<AchievementLevel> levels;

  AchievementResponse({required this.levels});

  factory AchievementResponse.fromJson(Map<String, dynamic> json) {
    return AchievementResponse(
      levels: (json["levels"] as List? ?? [])
          .map((e) => AchievementLevel.fromJson(e))
          .toList(),
    );
  }


}



class AchievementLevel {
  final int level;
  final bool isUnlocked;
  final double progress;
  final int pointsRemaining;
  final List<AchievementTask> tasks;

  AchievementLevel({
    required this.level,
    required this.isUnlocked,
    required this.progress,
    required this.pointsRemaining,
    required this.tasks,
  });

  factory AchievementLevel.fromJson(Map<String, dynamic> json) {
    return AchievementLevel(
      level: json["level"] ?? 0,
      isUnlocked: json["is_unlocked"] ?? false,
      progress: (json["progress"] ?? 0).toDouble(),
      pointsRemaining: json["points_remaining"] ?? 0,
      tasks: (json["tasks"] as List? ?? [])
          .map((e) => AchievementTask.fromJson(e))
          .toList(),
    );
  }
}

class AchievementTask {
  final String title;
  final String status; // completed/ongoing/pending

  AchievementTask({required this.title, required this.status});

  factory AchievementTask.fromJson(Map<String, dynamic> json) {
    return AchievementTask(
      title: json["title"] ?? "",
      status: json["status"] ?? "pending",
    );
  }

}
