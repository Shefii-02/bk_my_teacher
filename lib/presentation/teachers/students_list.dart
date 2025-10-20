import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/launch_status_service.dart';
import '../../services/teacher_api_service.dart';

class StudentsList extends StatefulWidget {
  final String teacherId;
  const StudentsList({super.key, required this.teacherId});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  late Future<Map<String, dynamic>> _teacherDataFuture;

  @override
  void initState() {
    super.initState();
    // Fetch teacher + students info from API
    _teacherDataFuture =
        TeacherApiService().fetchTeacherData(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _teacherDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("No student data found")),
          );
        }

        final teacher = snapshot.data!;
        final userId = teacher['user']['id'].toString();

        // Example: assume API returns teacher['students'] as a list
        final List<dynamic> students = teacher['students'] ?? [];

        return Scaffold(
          body: Stack(
            children: [
              // Background Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background/full-bg.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: [
                  // Top Section
                  SizedBox(
                    height: 110,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_left_sharp,
                                    color: Colors.black,
                                  ),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    context.push(
                                      '/teacher-dashboard',
                                      extra: {'teacherId': userId},
                                    );
                                  },
                                ),
                              ),
                              const Text(
                                "Students List",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(width: 50),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Section
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: students.isEmpty
                          ? const Center(
                        child: Text("No students assigned yet"),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: student['avatar'] != null
                                    ? NetworkImage(student['avatar'])
                                    : const AssetImage(
                                    'assets/images/default-avatar.png')
                                as ImageProvider,
                              ),
                              title: Text(student['name'] ?? 'Unknown'),
                              subtitle: Text(
                                  "Email: ${student['email'] ?? 'N/A'}"),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
