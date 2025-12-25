import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/presentation/students/teacher_details_page.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/image_paths.dart';
import '../widgets/teacher_profile_card.dart';

class TeachersList extends StatefulWidget {

  const TeachersList({super.key});

  @override
  State<TeachersList> createState() => _TeachersListState();
}

class _TeachersListState extends State<TeachersList> {
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final result = await ApiService().fetchSubjects();
      if (mounted) {
        setState(() {
          subjects = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading subjects: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Background
          // CachedNetworkImage(
          //   imageUrl:AppConfig.bodyBg,
          //   fit: BoxFit.cover,
          //   height: double.infinity,
          //   width: double.infinity,
          // ),
          Image.asset(
            ImagePaths.appBg,
            fit: BoxFit.contain,
            // height: double.infinity,
            // width: double.infinity,
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              _buildHeader(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _buildSubjectList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(
                Icons.arrow_back,
                    () => context.push(
                      '/student-dashboard'
                    ),
              ),
              const Text(
                "Teachers List",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return ListView.builder(
      // padding: const EdgeInsets.all(20),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final teachers = List<Map<String, dynamic>>.from(subject['available_teachers']);
        return Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject title
              Padding(
                padding: const EdgeInsets.only(left:12.0),
                child: Text(
                  subject['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   subject['description'] ?? '',
              //   style: const TextStyle(color: Colors.grey),
              // ),
              const SizedBox(height: 12),

              // Teachers carousel
              CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 0.6,
                  height: 180, // enough for 2 stacked cards
                ),
                itemCount: teachers.length,
                itemBuilder: (context, teacherIndex, _) {
                  final teacher = teachers[teacherIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // 👈 Gap between cards
                    child: TeacherProfileCard(name: teacher['name'], qualification: teacher['qualification'], subjects: teacher['subjects'], ranking: teacher['ranking'], rating: teacher['rating'], imageUrl: teacher['imageUrl'], onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TeacherDetailsPage(teacher: teacher),
                        ),
                      );
                    },),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildTeacherCard(Map<String, dynamic> teacher) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 5),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       color: Colors.white,
  //       boxShadow: const [
  //         BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         // Teacher image
  //         ClipRRect(
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //           child: CachedNetworkImage(
  //             imageUrl: teacher['imageUrl'] ?? '',
  //             height: 110,
  //             width: double.infinity,
  //             fit: BoxFit.cover,
  //             placeholder: (context, url) => const Center(
  //               child: CircularProgressIndicator(strokeWidth: 2),
  //             ),
  //             errorWidget: (context, url, error) => const Icon(Icons.error),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 teacher['name'] ?? '',
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 14,
  //                 ),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               Text(
  //                 teacher['qualification'] ?? '',
  //                 style: const TextStyle(color: Colors.grey, fontSize: 12),
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               Row(
  //                 children: [
  //                   const Icon(Icons.star, color: Colors.orange, size: 16),
  //                   Text(
  //                     "${teacher['rating'] ?? 0}",
  //                     style: const TextStyle(fontSize: 12),
  //                   ),
  //                   const Spacer(),
  //                   Text(
  //                     "Rank ${teacher['ranking']}",
  //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        iconSize: 22,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
