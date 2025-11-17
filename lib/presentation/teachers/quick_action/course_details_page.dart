import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart';
import '../../../services/teacher_api_service.dart';
import 'course_details_content.dart';

class CourseDetailsPage extends StatefulWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Future<CourseDetails> futureDetails;

  @override
  void initState() {
    super.initState();
    futureDetails = TeacherApiService().fetchTeacherCourseSummary(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CourseDetails>(
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
            body: CourseDetailsContent(course: details),
          );
        },
      ),
    );
  }
}
