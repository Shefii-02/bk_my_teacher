import 'dart:ui';

import 'package:BookMyTeacher/presentation/teachers/quick_action/achievements_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/level_data.dart';
import '../../providers/level_provider.dart';

class StudentAchievementCardSection extends StatefulWidget {
  const StudentAchievementCardSection({super.key});

  @override
  State<StudentAchievementCardSection> createState() => _StudentAchievementCardSectionState();
}

class _StudentAchievementCardSectionState extends State<StudentAchievementCardSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final levelAsync = ref.watch(currentLevelProvider);

        return levelAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text("Error: $e"),
          data: (level) {
            double progress =
                level.currentPoints / level.pointsToReachNext;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dedications & Achievements",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => AchievementsSheet(),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                _buildLevelCard(level, progress),

              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLevelCard(LevelData level, double progress) {
    return Container(
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
          LevelStatusBadge(
            level: level.currentLevel,
            pointsRemaining: level.pointsNeededForNext,
          ),

          const SizedBox(height: 15),

          GoldProgressBar(
            progress: progress,
            leftValue: level.currentLevel,
            rightValue: level.nextLevel,
            centerText:
            '${level.currentPoints}/${level.pointsToReachNext}',
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

}



class GoldProgressBar extends StatelessWidget {
  final double progress; // from 0.0 to 1.0
  final int leftValue;
  final int rightValue;
  final String centerText;

  const GoldProgressBar({
    super.key,
    required this.progress,
    this.leftValue = 2,
    this.rightValue = 3,
    this.centerText = '5200/6000',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blurred background glow
        ClipRRect(
          borderRadius: BorderRadius.circular(130),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3B14E), Color(0xFFFFCE51)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(130),
              ),
            ),
          ),
        ),

        // Gold flat progress bar
        Container(
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(90),
          ),
          child: Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(90),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3B14E), Color(0xFFFFCE51)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Left circle + number
        Positioned(
          left: 30,
          child: Row(
            children: [
              _goldCircle(),
              const SizedBox(width: 4),
              Text(
                '$leftValue',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.8,
                  color: Color(0xFF825C24),
                ),
              ),
            ],
          ),
        ),

        // Center text
        Text(
          centerText,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14.8,
            color: Color(0xFF685613),
            letterSpacing: 0.025,
          ),
        ),

        // Right circle + trophy + number
        Positioned(
          right: 30,
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFF825C24),
                size: 16,
              ),
              const SizedBox(width: 4),
              _goldCircle(),
              const SizedBox(width: 4),
              Text(
                '$rightValue',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.8,
                  color: Color(0xFF825C24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _goldCircle() {
    return Container(
      width: 18, // slightly larger for border
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // border color
      ),
      child: Center(
        child: Container(
          width: 17,
          height: 17,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFF3B14E), Color(0xFFFFCE51)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

class LevelStatusBadge extends StatelessWidget {
  final int level;
  final int pointsRemaining;
  final IconData icon;

  const LevelStatusBadge({
    super.key,
    this.level = 2,
    this.pointsRemaining = 500,
    this.icon = Icons.emoji_events, // trophy icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left dark circular background with trophy
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A0F24),
                  border: Border.all(
                    color: const Color(0xFF3B4043),
                    width: 2.4,
                  ),
                ),
              ),
              Positioned(
                top: 6, // adds a small gap between icon and number
                child: Icon(icon, size: 22, color: const Color(0xFFFFDD64)),
              ),

              // Gradient text "2"
              Positioned(
                bottom: 2, // adds a small gap between icon and number
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color.fromRGBO(253, 253, 253, 0.97),
                      Color(0xFFFFDD64),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    "$level",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 15),

          // Right side texts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level $level',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 21,
                  letterSpacing: -0.37,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$pointsRemaining Points to next level',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.8,
                  letterSpacing: 0.02,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
