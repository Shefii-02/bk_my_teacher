import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
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
              // ✅ Navigate to single course details page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailPage(course: course),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(course['main_image'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
            ),
          );
        },
        options: CarouselOptions(
          height: 150,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
          enableInfiniteScroll: true,
          autoPlay: true,
        ),
      ),
    );
  }
}
