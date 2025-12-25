import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'base_card.dart';

class WebinarCards extends StatelessWidget {
  final Map<String, dynamic> webinar;
  final VoidCallback onTap;

  const WebinarCards({super.key, required this.webinar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: BaseCard(
        image: webinar['main_image_url'] ?? '',
        title: webinar['title'],
        description: webinar['description'] ?? '',
        duration: webinar['started_at'] != null
            ? DateFormat(
                'dd MMM yyyy • hh:mm a',
              ).format(DateTime.parse(webinar['started_at']))
            : '',
        level: webinar['level'] ?? '',
        badge: webinar['is_enrolled'] == true ? 'Registered' : '',
        actualPrice: webinar['actual_price'],
        netPrice: webinar['net_price'],
      ),
    );
  }
}
