import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../students/recorded_video_with_doubt.dart';
import '../widgets/show_failed_alert.dart';
import '../widgets/show_success_alert.dart';
import 'dart:io' show Platform;

class DemoClassDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> course;
  const DemoClassDetailBottomSheet({super.key, required this.course});

  @override
  State<DemoClassDetailBottomSheet> createState() =>
      DemoClassDetailBottomSheetState();
}

class DemoClassDetailBottomSheetState
    extends State<DemoClassDetailBottomSheet> {
  bool _submitting = false;
  bool _enrolled = false;
  Timer? _ticker;
  // Use a ValueNotifier for countdowns to avoid rebuilding whole widget every second
  final ValueNotifier<Map<String, Duration>> _countdownNotifier = ValueNotifier(
    {},
  );

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      showFailedAlert(
        context,
        title: 'Failed',
        subtitle: 'Error opening url: $e',
        timer: 2,
        color: Colors.red,
        showButton: false,
      );
    }
  }

  /// Optimized countdown: populate initial remaining durations in a map and
  /// tick once per second updating the ValueNotifier. Only widgets that listen
  /// to the notifier rebuild.
  void _setupCountdowns(List<dynamic> classes) {
    _ticker?.cancel();
    final Map<String, Duration> map = {};

    final now = DateTime.now();
    for (var c in classes) {
      try {
        final id = c['id'].toString();
        final dtStr = c['date_time']?.toString();
        if (dtStr != null && dtStr.isNotEmpty) {
          final dt = DateTime.parse(dtStr);
          if (dt.isAfter(now)) {
            map[id] = dt.difference(now);
          }
        }
      } catch (_) {
        // ignore parse errors
      }
    }

    _countdownNotifier.value = map;

    if (map.isEmpty) {
      _ticker?.cancel();
      return;
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = Map<String, Duration>.from(_countdownNotifier.value);
      bool changed = false;

      final keys = current.keys.toList();
      for (final k in keys) {
        final rem = current[k]!;
        if (rem.inSeconds <= 1) {
          current.remove(k);
          changed = true;
        } else {
          current[k] = rem - const Duration(seconds: 1);
          changed = true;
        }
      }

      if (changed) {
        _countdownNotifier.value = current;
      }

      if (current.isEmpty) {
        // stop timer when no countdowns left
        _ticker?.cancel();
      }
    });
  }

  String _humanDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Future<void> _onClassAction(Map<String, dynamic> c) async {
    final status = (c['status'] ?? '').toString().toLowerCase();
    final joinLink = c['meeting_url']?.toString();
    final recorded = c['recording_url']?.toString();
    final title = (c['title'] ?? '').toString();
    final source = (c['source'] ?? '').toString();

    if (status == 'ongoing') {
      if (joinLink != null && joinLink.isNotEmpty) {
        if (source == 'gmeet') {
          await _openUrl(joinLink);
        } else if (source == 'youtube') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecordedVideoWithDoubt(
                title: title,
                videoUrl: joinLink,
                classId: c['id'],
                type: 'Demo Class',
              ),
            ),
          );
        } else {
          showFailedAlert(
            context,
            title: 'Failed',
            subtitle: "Source link not available",
            timer: 2,
            color: Colors.red,
            showButton: false,
          );
        }
      } else {
        showFailedAlert(
          context,
          title: 'Failed',
          subtitle: "Join link not available",
          timer: 2,
          color: Colors.red,
          showButton: false,
        );
      }
    } else if (status == 'upcoming') {
      showFailedAlert(
        context,
        title: 'Failed',
        subtitle: "Class not started yet",
        timer: 2,
        color: Colors.red,
        showButton: false,
      );
    } else if (status == 'completed') {
      if (recorded != null && recorded.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordedVideoWithDoubt(
              title: title,
              videoUrl: recorded,
              classId: c['id'],
              type: 'Demo Class',
            ),
          ),
        );
      } else {
        showFailedAlert(
          context,
          title: 'Failed',
          subtitle: "Recording not available",
          timer: 2,
          color: Colors.red,showButton:false
        );
      }
    } else {
      showFailedAlert(
        context,
        title: 'Failed',
        subtitle: "Action not available",
        timer: 2,
        color: Colors.red,showButton:false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    _enrolled = _enrolled || (course['is_enrolled'] ?? false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // ===================== CONTENT =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dragHandle(),

                  // 🔥 HERO IMAGE
                  if ((course['main_image_url'] ?? '').isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        course['main_image_url'],
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 🔥 TITLE
                  Text(
                    course['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Html(
                    data: course['description'] ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(15),
                        lineHeight: LineHeight(1.5),
                        color: Colors.grey.shade700,
                      ),
                    },
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // 🔥 INFO ROWS
                  _infoRow(
                    Icons.schedule,
                    "Starts",
                    _formatDate(course['started_at']),
                  ),
                  _infoRow(
                    Icons.event,
                    "Ends",
                    _formatDate(course['ended_at']),
                  ),
                  _infoRow(
                    Icons.person,
                    "Instructor",
                    course['host']?['name'] ?? 'TBA',
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // ===================== STICKY PURCHASE BAR =====================
          Positioned(bottom: 0, left: 0, right: 0, child: _purchaseBar(course)),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  Widget _purchaseBar(Map<String, dynamic> course) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: GestureDetector(
        // onTap: _submitting || _enrolledCourse ? null : _enrollCourse,
        onTap: () {
          _onClassAction(course);
          // if (course['provider']['slug'] == 'gmeet') {
          //   print(course['meeting_url']);
          // } else {
          //   print('object');
          // }
        },

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: _enrolled
                ? null
                : const LinearGradient(
                    colors: [Color(0xff16a34a), Color(0xff22c55e)],
                  ),
            color: _enrolled ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: const ValueKey("enrolled"),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Watch Class',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return 'TBA';
    return DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(date));
  }
}

Widget priceView({required dynamic actualPrice, required dynamic netPrice}) {
  if (netPrice == null) return const SizedBox.shrink();

  final actual = double.tryParse(actualPrice.toString());
  final net = double.tryParse(netPrice.toString());

  if (actual == null || net == null) {
    return const SizedBox.shrink();
  }

  // 🎯 If discounted
  if (actual > net) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(
            "₹${actual.toStringAsFixed(0)}",
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.red,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "₹${net.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 No discount
  return Text(
    "₹${net.toStringAsFixed(0)}",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25,
      color: Colors.white,
    ),
  );
}
