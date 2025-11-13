import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/student_api_service.dart';
import '../webinars/webinar_listing.dart';

class MyClassList extends StatefulWidget {
  final String studentId;
  const MyClassList({super.key, required this.studentId});

  @override
  State<MyClassList> createState() => _MyClassListState();
}

class _MyClassListState extends State<MyClassList> {
  late Future<Map<String, dynamic>> _studentDataFuture;

  @override
  void initState() {
    super.initState();
    final api = StudentApiService();
    _studentDataFuture = api.fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _studentDataFuture,
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

        final student = snapshot.data!;
        final userId = student['user']?['id']?.toString() ?? '';

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
                                      '/student-dashboard'
                                    );
                                  },
                                ),
                              ),

                              // Title
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "My Class List",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 40),
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Free Webinars",
                              style: TextStyle(fontSize: 16),
                            ),
                            WebinarListPage(),
                          ],
                        ),
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
