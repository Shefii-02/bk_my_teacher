class LevelData {
  final int currentLevel;
  final int currentPoints;
  final int nextLevel;
  final int pointsToReachNext;
  final int pointsNeededForNext;

  LevelData({
    required this.currentLevel,
    required this.currentPoints,
    required this.nextLevel,
    required this.pointsToReachNext,
    required this.pointsNeededForNext,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      currentLevel: json['current_level'],
      currentPoints: json['current_points'],
      nextLevel: json['next_level'],
      pointsToReachNext: json['points_to_reach_next'],
      pointsNeededForNext: json['points_needed_for_next'],
    );
  }
}
