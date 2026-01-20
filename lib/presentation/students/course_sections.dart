import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../components/course_detail_bottom_sheet.dart';
import '../components/webinar_detail_bottom_sheet.dart';
import '../components/workshop_detail_bottom_sheet.dart';
import 'course_detail_page.dart';

class CourseSections extends StatefulWidget {
  const CourseSections({super.key});

  @override
  State<CourseSections> createState() => _CourseSectionsState();
}

class _CourseSectionsState extends State<CourseSections> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourseBanner();
  }

  Future<void> _fetchCourseBanner() async {
    try {
      final result = await ApiService().fetchCourseBanners();
      if (mounted) {
        setState(() {
          courses = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading course banners: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courses.isEmpty) {
      return const Center(child: Text("No courses available"));
    }

    return Center(
      child: CarouselSlider.builder(
        itemCount: courses.length,
        itemBuilder: (context, index, realIndex) {
          final course = courses[index];
          return GestureDetector(

            onTap: () {
              switch (course['type']) {
                case 'webinar':
                  _showWebinarDetail(context, course);
                  break;

                case 'workshop':
                  _showWorkshopDetail(context, course);
                  break;

                case 'course':
                  _showCourseDetail(context, course);
                  break;

                default:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailPage(course: course),
                    ),
                  );
              }
            },
            child: course['thumb'] != '' ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(course['thumb'] ?? ''),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.green.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                // child: Text(
                //   course['title'] ?? 'Untitled Course',
                //   style: const TextStyle(
                //     color: Colors.white,
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ),
            ) : SizedBox(),
          );
        },
        options: CarouselOptions(
          height: 180,
          enlargeCenterPage: true,
          viewportFraction: 0.75,
          enableInfiniteScroll: true,
          autoPlay: true,
        ),
      ),
    );
  }


  // ================= Bottom Sheets =================

  void _showCourseDetail(BuildContext context, course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourseDetailBottomSheet(
        course: course['type_details'],
        redirectTo: '/student-course-store',
      ),
    );
  }

  void _showWebinarDetail(BuildContext context, course) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WebinarDetailBottomSheet(
        course: course['type_details'],
        redirectTo: '/student-course-store',
      ),
    );
  }

  void _showWorkshopDetail(BuildContext context, course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkshopDetailBottomSheet(
        course: course['type_details'],
        redirectTo: '/student-course-store',
      ),
    );
  }
}
