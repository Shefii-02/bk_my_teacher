import 'package:flutter/material.dart';
import '../../../model/course_details_model.dart';
import '../../../model/course_model.dart';
import '../../../services/teacher_api_service.dart';
import 'course_details_page.dart';

class OwnCoursesSheet extends StatefulWidget {
  const OwnCoursesSheet({super.key});

  @override
  State<OwnCoursesSheet> createState() => _OwnCoursesSheetState();
}

class _OwnCoursesSheetState extends State<OwnCoursesSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool loading = true;
  bool error = false;

  CourseSummary? summary;

  final Map<String, List<CourseItem>> courses = {
    "Upcoming": [],
    "Ongoing": [],
    "Completed": [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: courses.keys.length, vsync: this);
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      setState(() => loading = true);

      summary = await TeacherApiService().fetchTeacherCourses();

      courses["Upcoming"] = summary!.upcoming;
      courses["Ongoing"] = summary!.ongoing;
      courses["Completed"] = summary!.completed;

      setState(() {
        loading = false;
        error = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "📚 My Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // LOADING
              if (loading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator())),

              // ERROR
              if (!loading && error)
                Expanded(
                  child: Center(
                    child: Text("Failed to load courses"),
                  ),
                ),

              // SUCCESS
              if (!loading && !error) ...[
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blueAccent,
                  tabs: courses.keys.map((e) => Tab(text: e)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: courses.keys.map((tab) {
                      final list = courses[tab]!;

                      if (list.isEmpty) {
                        return const Center(
                          child: Text("No courses available"),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final course = list[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  course.thumbnailUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(course.title),
                              subtitle: Text(
                                "${course.startDate} | ${course.startTime}",
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseDetailsPage(courseId: course.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // void _showCourseDetails(BuildContext context, CourseItem course) async {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     showDragHandle: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return FutureBuilder<CourseDetails>(
  //         future: TeacherApiService().fetchTeacherCourseSummary(course.id),
  //         builder: (context, snapshot) {
  //           if (!snapshot.hasData) {
  //             return const SizedBox(
  //               height: 400,
  //               child: Center(child: CircularProgressIndicator()),
  //             );
  //           }
  //
  //           final data = snapshot.data!;
  //           final courseInfo = data.course;
  //
  //           return DraggableScrollableSheet(
  //             expand: false,
  //             initialChildSize: 0.95,
  //             maxChildSize: 0.95,
  //             minChildSize: 0.6,
  //             builder: (_, controller) {
  //               return Column(
  //                 children: [
  //                   // Banner + Title
  //                   ClipRRect(
  //                     borderRadius:
  //                     const BorderRadius.vertical(top: Radius.circular(20)),
  //                     child: Image.network(
  //                       courseInfo.thumbnailUrl,
  //                       height: 180,
  //                       width: double.infinity,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //
  //                   Padding(
  //                     padding: const EdgeInsets.all(16.0),
  //                     child: Text(
  //                       courseInfo.title,
  //                       style: const TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //
  //                   // Tabs
  //                   DefaultTabController(
  //                     length: 3,
  //                     child: Expanded(
  //                       child: Column(
  //                         children: [
  //                           const TabBar(
  //                             labelColor: Colors.blue,
  //                             unselectedLabelColor: Colors.grey,
  //                             tabs: [
  //                               Tab(text: "About"),
  //                               Tab(text: "Classes"),
  //                               Tab(text: "Materials"),
  //                             ],
  //                           ),
  //
  //                           Expanded(
  //                             child: TabBarView(
  //                               children: [
  //                                 // ABOUT TAB
  //                                 _aboutTab(courseInfo),
  //
  //                                 // CLASSES TAB
  //                                 _classesTab(data.classes, controller),
  //
  //                                 // MATERIAL TAB
  //                                 _materialsTab(data.materials),
  //                               ],
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  // Widget _aboutTab(CourseInfo c) {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: ListView(
  //       children: [
  //         Text(c.description, style: const TextStyle(fontSize: 15)),
  //         const SizedBox(height: 20),
  //
  //         Row(
  //           children: [
  //             const Icon(Icons.timer_outlined),
  //             SizedBox(width: 8),
  //             Text("Duration: ${c.duration}"),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //
  //         Row(
  //           children: [
  //             const Icon(Icons.bar_chart_outlined),
  //             SizedBox(width: 8),
  //             Text("Level: ${c.level}"),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //
  //         Row(
  //           children: [
  //             const Icon(Icons.language),
  //             SizedBox(width: 8),
  //             Text("Language: ${c.language}"),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //
  //         Row(
  //           children: [
  //             const Icon(Icons.category_outlined),
  //             SizedBox(width: 8),
  //             Text("Category: ${c.category}"),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // Widget _classesTab(ClassGroups groups, ScrollController controller) {
  //   return ListView(
  //     controller: controller,
  //     padding: const EdgeInsets.all(16),
  //     children: [
  //       if (groups.upcoming.isNotEmpty) _classSection("Upcoming", groups.upcoming),
  //       if (groups.ongoing.isNotEmpty) _classSection("Ongoing", groups.ongoing),
  //       if (groups.completed.isNotEmpty) _classSection("Completed", groups.completed),
  //     ],
  //   );
  // }
  //
  // Widget _classSection(String title, List<ClassItem> list) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title,
  //           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 10),
  //       ...list.map((c) => Card(
  //         child: ListTile(
  //           title: Text(c.title),
  //           subtitle: Text("${c.date} | ${c.timeStart} - ${c.timeEnd}"),
  //         ),
  //       )),
  //       const SizedBox(height: 20),
  //     ],
  //   );
  // }
  //
  // Widget _materialsTab(List<MaterialItem> materials) {
  //   return ListView(
  //     padding: const EdgeInsets.all(16),
  //     children: materials.map((m) {
  //       IconData icon = Icons.insert_drive_file;
  //
  //       if (m.fileType == "pdf") icon = Icons.picture_as_pdf;
  //       if (m.fileType == "video") icon = Icons.video_library_outlined;
  //
  //       return Card(
  //         child: ListTile(
  //           leading: Icon(icon, size: 32),
  //           title: Text(m.title),
  //           trailing: const Icon(Icons.download),
  //           onTap: () {
  //             // TODO: open or download file
  //           },
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

}
