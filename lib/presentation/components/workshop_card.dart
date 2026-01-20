import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_card.dart';
class WorkshopCard extends StatelessWidget {
  final Map<String, dynamic> workshop;
  final VoidCallback onTap;

  const WorkshopCard({
    super.key,
    required this.workshop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: BaseCard(
        image: workshop['main_image_url'] ?? '',
        title: workshop['title'],
        description: workshop['description'] ?? '',
        duration: workshop['started_at'] != null
            ? DateFormat(
          'dd MMM yyyy • hh:mm a',
        ).format(DateTime.parse(workshop['started_at']))
            : '',
        level: workshop['level'] ?? '',
        badge: workshop['is_enrolled'] == true ? 'Access Granted' : '',
        actualPrice: workshop['actual_price'],
        netPrice: workshop['net_price'],
      ),
    );
  }
}
