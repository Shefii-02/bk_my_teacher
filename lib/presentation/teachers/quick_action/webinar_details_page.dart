import 'package:BookMyTeacher/presentation/teachers/quick_action/webinar_details_content.dart';
import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart';
import '../../../model/webinar_details_model.dart';
import '../../../services/teacher_api_service.dart';
import 'course_details_content.dart';

class WebinarDetailsPage extends StatefulWidget {
  final int courseId;

  const WebinarDetailsPage({super.key, required this.courseId});

  @override
  State<WebinarDetailsPage> createState() => _WebinarDetailsPageState();
}

class _WebinarDetailsPageState extends State<WebinarDetailsPage> {
  late Future<WebinarDetailsModel> futureDetails;

  @override
  void initState() {
    super.initState();
    futureDetails = TeacherApiService().fetchTeacherWebinarSummary(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WebinarDetailsModel>(
        future: futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final details = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(details.course.title),
            ),
            body: WebinarDetailsContent(course: details),
          );
        },
      ),
    );
  }
}
