import 'package:BookMyTeacher/presentation/teachers/quick_action/workshop_details_content.dart';
import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart';
import '../../../model/workshop_details_model.dart';
import '../../../services/teacher_api_service.dart';
import 'course_details_content.dart';

class StudentWorkshopDetailsPage extends StatefulWidget {
  final int courseId;

  const StudentWorkshopDetailsPage({super.key, required this.courseId});

  @override
  State<StudentWorkshopDetailsPage> createState() => _StudentWorkshopDetailsPageState();
}

class _StudentWorkshopDetailsPageState extends State<StudentWorkshopDetailsPage> {
  late Future<WorkshopDetailsModel> futureDetails;

  @override
  void initState() {
    super.initState();
    futureDetails = TeacherApiService().fetchTeacherWorkshopSummary(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WorkshopDetailsModel>(
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
              title: Text(details.workshop.title),
            ),
            body: WorkshopDetailsContent(workshop: details,),
          );
        },
      ),
    );
  }
}
