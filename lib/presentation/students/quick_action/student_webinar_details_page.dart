import 'package:BookMyTeacher/presentation/teachers/quick_action/webinar_details_content.dart';
import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart';
import '../../../model/webinar_details_model.dart';
import '../../../services/teacher_api_service.dart';
import 'course_details_content.dart';

class StudentWebinarDetailsPage extends StatefulWidget {
  final int courseId;

  const StudentWebinarDetailsPage({super.key, required this.courseId});

  @override
  State<StudentWebinarDetailsPage> createState() => _StudentWebinarDetailsPageState();
}

class _StudentWebinarDetailsPageState extends State<StudentWebinarDetailsPage> {
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
