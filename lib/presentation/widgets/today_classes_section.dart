import 'package:BookMyTeacher/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/today_class_model.dart';
import '../record_section/video_class_screen.dart';
import '../students/recorded_video_with_doubt.dart';

class TodayClassesSection extends StatefulWidget {
  const TodayClassesSection({Key? key}) : super(key: key);

  @override
  State<TodayClassesSection> createState() => _TodayClassesSectionState();
}

class _TodayClassesSectionState extends State<TodayClassesSection> {
  List<TodayClassModel> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodayClasses();
  }

  Future<void> fetchTodayClasses() async {
    try {
      final response = await ApiService().getTodayClasses();
      setState(() {
        classes = response; // directly assign list
        isLoading = false;
      });
    } catch (e) {
      print("API Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Today's Classes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        /// 🔄 Loading
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        /// ❌ Empty
        else if (classes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No classes scheduled today"),
          )
        /// ✅ Data
        else
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final item = classes[index];
                return _buildClassCard(item);
              },
            ),
          ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildClassCard(TodayClassModel item) {
    Color statusColor;
    String buttonText;

    switch (item.status) {
      case "live":
        statusColor = Colors.red;
        buttonText = "Join Now";
        break;
      case "ongoing":
        statusColor = Colors.red;
        buttonText = "Join Now";
        break;
      case "upcoming":
        statusColor = Colors.orange;
        buttonText = "Upcoming";
        break;
      default:
        statusColor = Colors.blueAccent;
        buttonText = " Watch Recorded Class";
    }

    return Container(
      width: 300,
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.type,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_filled_sharp, size: 12, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                item.time,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),SizedBox(width: 4),
              Text(
                item.timeEnd,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            item.title.length > 30
                ? "${item.title.substring(0, 30)}.."
                : item.title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            item.subject.length > 30
                ? "${item.subject.substring(0, 30)}.."
                : item.subject,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Text(
            item.course.length > 30
                ? "${item.course.substring(0, 30)}.."
                : item.course,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _onClassAction(
                item.platform,
                item.meetingLink,
                item.title,
                item.id,
                item.type,
                item.status,
                item.recordedLink,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(buttonText, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _onClassAction(
    String? platform,
    String? joinLink,
    String title,
    int id,
    String type,
    String status,
    String? recordedLink,
  ) async {
    /// 🔴 LIVE CLASS

    if (status == 'live' || status == 'ongoing') {
      if (joinLink != null && joinLink.isNotEmpty) {
        if (platform == 'gmeet') {
          await _openUrl(joinLink);
        } else if (platform == 'youtube') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              VideoClassScreen(title: title, videoUrl: joinLink, classId: id.toString(), type: type,)
              //     RecordedVideoWithDoubt(
              //   title: title,
              //   videoUrl: joinLink,
              //   classId: id.toString(),
              //   type: type,
              // ),
            ),
          );
        } else {
          _showSnack("Source link not available");
        }
      } else {
        _showSnack("Class link not available");
      }
    }
    /// 🟢 COMPLETED CLASS
    else if (status == 'completed') {
      if (recordedLink != null && recordedLink.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VideoClassScreen(title: title, videoUrl: recordedLink, classId: id.toString(), type: type,)
            //     RecordedVideoWithDoubt(
            //   title: title,
            //   videoUrl: recordedLink,
            //   classId: id.toString(),
            //   type: type,
            // ),
          ),
        );
      } else {
        _showSnack("Recording not available");
      }
    }
    /// 🟡 UPCOMING CLASS
    else if (status == 'upcoming') {
      _showSnack("Class not started yet");
    }
    /// ⚫ UNKNOWN
    else {
      _showSnack("Class not available");
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnack('Error opening url: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
