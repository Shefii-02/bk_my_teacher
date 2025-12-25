import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_card.dart';
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print(course);
    return InkWell(
      onTap: onTap,
      child: BaseCard(
        image: course['main_image_url'] ?? '',
        title: course['title'] ?? '',
        description: course['description'] ?? '',
        duration: course['started_at'] != null
            ? DateFormat(
          'dd MMM yyyy • hh:mm a',
        ).format(DateTime.parse(course['started_at']))
            : '',
        level: course['level'] ?? '',
        badge: course['is_enrolled'] == true ? 'Registered' : '',
        actualPrice: course['actual_price'],
        netPrice: course['net_price'],
      ),
    );
  }
}
