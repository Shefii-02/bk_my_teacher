import 'dart:ui';
import 'package:flutter/material.dart';

import '../dashboard_home.dart';

class AchievementsSheet extends StatelessWidget {
  const AchievementsSheet({super.key});

  final List<Map<String, dynamic>> levels = const [
    {"level": 1, "pointsRemaining": 0, "progress": 1.0},
    {"level": 2, "pointsRemaining": 500, "progress": 0.7},
    {"level": 3, "pointsRemaining": 1200, "progress": 0.2},
    {"level": 4, "pointsRemaining": 3000, "progress": 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Text(
                  "🏆 My Achievements",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // List of Level Cards
              ...levels.map((levelData) {
                return _buildLevelCard(
                  level: levelData['level'],
                  pointsRemaining: levelData['pointsRemaining'],
                  progress: levelData['progress'],
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelCard({
    required int level,
    required int pointsRemaining,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LevelStatusBadge(level: level, pointsRemaining: pointsRemaining),
          const SizedBox(height: 15),
          GoldProgressBar(
            progress: progress,
            leftValue: level,
            rightValue: level + 1,
            centerText: "${(progress * 100).toInt()}/100%",
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
