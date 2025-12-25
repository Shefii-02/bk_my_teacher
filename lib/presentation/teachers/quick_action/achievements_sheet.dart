import 'dart:ui';
import 'package:BookMyTeacher/presentation/widgets/show_success_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/achievement_level.dart';
import '../../../providers/achievements_provider.dart';
import '../dashboard_home.dart';
import '../student_achievement_card_section.dart';

class AchievementsSheet extends ConsumerWidget {
  const AchievementsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(achievementsProvider);

    return asyncData.when(
      loading: () => const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (response) {
        final levels = response.levels;

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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (levels.isEmpty)
                    const Center(
                      child: Text(
                        "No levels available",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                  ...levels.map((lvl) => _buildLevelCard(context, lvl)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 LEVEL CARD — USING YOUR UI EXACTLY
  Widget _buildLevelCard(BuildContext context, AchievementLevel lvl) {
    return Opacity(
      opacity: lvl.isUnlocked ? 1.0 : 0.65,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
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
            // 🔥 Title row (LevelStatusBadge + Info Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LevelStatusBadge(
                    level: lvl.level,
                    pointsRemaining: lvl.pointsRemaining,
                  ),
                ),

                InkWell(
                  onTap: () => lvl.progress <= 0
                      ? {
                          ShowSuccessAlert(
                            title: "Level is Locked",
                            subtitle:
                                "Please complete previous levels to unlock this level.",
                            timer: 3,
                            color: Colors.red,
                          ),
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text("This level has no tasks yet."),
                          //   ),
                          // ),
                        }
                      : _showLevelTasks(context, lvl),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.info_outline, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            GoldProgressBar(
              progress: lvl.progress,
              leftValue: lvl.level,
              rightValue: lvl.level + 1,
              centerText: "${(lvl.progress * 100).toInt()}%",
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 🔥 Bottom Sheet — Shows tasks of selected level
  void _showLevelTasks(BuildContext context, AchievementLevel lvl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          minChildSize: 0.4,

          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Text(
                      "Level ${lvl.level} Tasks",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...lvl.tasks.map((task) => _buildTaskItem(task)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 Task Item UI (same as yours)
  Widget _buildTaskItem(AchievementTask task) {
    Color badgeColor;
    switch (task.status) {
      case "completed":
        badgeColor = Colors.green;
        break;
      case "ongoing":
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
