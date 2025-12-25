import 'package:BookMyTeacher/presentation/teachers/quick_action/achievements_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/my_schedules_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/own_courses_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/rating_reviews.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/statistics_sheet.dart';
import 'package:flutter/material.dart';

class TeacherQuickActions extends StatelessWidget {
  const TeacherQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        "icon": "assets/images/icons/schedules.png",
        "label": "My Schedules",
        "widget": const SchedulesSheet(),
      },
      {
        "icon": "assets/images/icons/courses.png",
        "label": "Courses",
        "widget": const OwnCoursesSheet(),
      },
      {
        "icon": "assets/images/icons/statistics.png",
        "label": "Statistics",
        "widget": const StatisticsSheet(),
      },
      {
        "icon": "assets/images/icons/rating.png",
        "label": "Rating",
        "widget": const RatingsReviewsSheet(),
      },
      {
        "icon": "assets/images/icons/achievements.png",
        "label": "Achievements",
        "widget": const AchievementsSheet(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((item) {
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => item["widget"] as Widget,
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        item['icon'] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 8,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
