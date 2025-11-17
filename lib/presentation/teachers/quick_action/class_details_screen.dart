
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/schedule_model.dart';

class ClassDetailsScreen extends StatelessWidget {
  final ScheduleEvent event;
  final DateTime dateKey; // date of the event (UTC Y-M-D)

  const ClassDetailsScreen({super.key, required this.event, required this.dateKey});

  @override
  Widget build(BuildContext context) {
    final start = event.startDateFor("${dateKey.year.toString().padLeft(4,'0')}-${dateKey.month.toString().padLeft(2,'0')}-${dateKey.day.toString().padLeft(2,'0')}");
    return Scaffold(
      appBar: AppBar(title: Text(event.topic)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (event.thumbnailUrl != null)
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.network(event.thumbnailUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
              // ),
            const SizedBox(height: 12),
            Text(event.topic, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text("${dateKey.toLocal().toIso8601String().split('T').first} • ${event.timeStart} - ${event.timeEnd}"),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.person_outline, size: 16),
              const SizedBox(width: 6),
              Text("Host: ${event.hostName}"),
            ]),
            const SizedBox(height: 12),
            Text(event.description),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _infoTile("Subject", event.subjectName),
              _infoTile("Type", event.classType),
              _infoTile("Status", event.classStatus),
              _infoTile("Attendance", event.attendanceRequired ? "Required" : "Optional"),
              _infoTile("Duration", event.duration != null ? "${event.duration} min" : "${event.timeStart} - ${event.timeEnd}"),
              if (event.courseId != null) _infoTile("Course", event.courseId.toString()),
            ]),
            const SizedBox(height: 18),
            // link / password / students
            if (event.classLink != null) Text("Link: ${event.classLink}"),
            if (event.meetingPassword != null) Text("Password: ${event.meetingPassword}"),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.play_circle_outline, size: 16),
                const SizedBox(width: 6),
                Text("Source: ${event.source.toUpperCase()}"),
              ],
            ),
            const SizedBox(height: 20),

            if (event.classLink != null)
              ElevatedButton.icon(
                onPressed: () => joinClassFromEvent(event, context),
                icon: const Icon(Icons.video_camera_front_outlined, color: Colors.white),
                label: const Text("Join Class", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.video_camera_front_outlined, color: Colors.white),
                label: const Text("Class Not Created", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.grey,
                ),
              ),

            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Chip(
      label: Text("$title: $value"),
    );
  }

  void joinClassFromEvent(ScheduleEvent event, BuildContext context) {
    final link = event.classLink;

    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid class link")));
      return;
    }

    switch (event.source.toLowerCase()) {
      case "gmeet":
        launchUrl(Uri.parse(link));
        break;
      case "youtube":
        context.push('/youtube-player', extra: link);
        break;

      case "zoom":
        context.push('/zoom-meeting', extra: event);
        break;

      case "agora":
        context.push('/agora-class', extra: event);
        break;

      case "zegocloud":
        context.push('/zego-class', extra: event);
        break;

      case "aws":
      case "aws_ivs":
        context.push('/aws-ivs-player', extra: link);
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown class source: ${event.source}")),
        );
    }
  }
}


class PlaceholderScreenForJoin extends StatelessWidget {
  final ScheduleEvent event;
  final DateTime dateKey;
  const PlaceholderScreenForJoin({super.key, required this.event, required this.dateKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join / Streaming"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Here you'll handle routing by 'class_link' and 'class source' (zoom, gmeet, youtube, agora, etc.)."),
            const SizedBox(height: 12),
            Text("Event: ${event.topic}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // placeholder: go back
                Navigator.pop(context);
              },
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
