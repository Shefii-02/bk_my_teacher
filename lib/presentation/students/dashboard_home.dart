import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/presentation/students/course_sections.dart';
import 'package:BookMyTeacher/presentation/students/request_form.dart';
import 'package:BookMyTeacher/presentation/students/subject_carousel.dart';
import 'package:BookMyTeacher/presentation/students/teacher_carousel.dart';
import 'package:BookMyTeacher/presentation/students/teacher_carousel_single_row.dart';
import 'package:BookMyTeacher/presentation/students/teacher_carousel_two.dart';
import 'package:BookMyTeacher/presentation/students/teacher_profile_card.dart';
import 'package:BookMyTeacher/presentation/widgets/connect_with_team.dart';
import 'package:BookMyTeacher/presentation/widgets/social_media_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/browser_service.dart';
import '../../services/student_api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/top_banner_carousel.dart';
import 'package:animate_do/animate_do.dart';

import '../widgets/wallet_section.dart';
import 'invite_friends_card.dart';

class DashboardHome extends StatefulWidget {
  final Future<Map<String, dynamic>> studentDataFuture;
  const DashboardHome({
    super.key,
    required this.studentDataFuture
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Map<String, dynamic>> _studentDataFuture;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _studentDataFuture = widget.studentDataFuture;
  }

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.microphone, Permission.contacts].request();
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
        final stepsData = student['steps'] as List<dynamic>;
        final avatar = student['avatar'] ?? "https://via.placeholder.com/150";
        final name = student['user']['name'] ?? "Unknown student";

        return Scaffold(
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(AppConfig.bodyBg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  // padding:
                  // const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      // const SizedBox(height: 10),
                      // ---------- Header ----------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(avatar),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.grey[800],
                              ),
                              iconSize: 30,
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 10),
                      TopBannerCarousel(),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        // padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // ---------- Request Class Section ----------
                            RequestForm(),
                            const SizedBox(height: 20),
                            InviteFriendsCard(),
                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                right: 12.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x52B0FFDF),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                ),
                                child: WalletSection(),
                              ),
                            ),

                            const SizedBox(height: 20),
                            // ---------- Top Teachers ----------
                            const Text(
                              'Learn from the Best Teachers Around You',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TeacherCarouselTwoRows(),
                            const Text(
                              'We’re Providing Subjects',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // ---------- Providing Subjects ----------
                            SubjectCarousel(),
                            const SizedBox(height: 40),
                            // ---------- Providing Courses ----------
                            const Text(
                              'Discover Courses That Fit Your Goals',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            CourseSections(),
                            const SizedBox(height: 40),
                            SocialMediaIcons(),
                            const SizedBox(height: 40),
                            ConnectWithTeam(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildProvidingSubjectsSection() =>
      _buildChipSection('Providing Subjects');
  Widget _buildProvidingCoursesSection() =>
      _buildChipSection('Providing Courses');

  Widget _buildChipSection(String title) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            6,
            (index) => Chip(
              label: Text('$title ${index + 1}'),
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          ),
        ),
      ],
    ),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 5),
    ],
  );
}

//
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
//
// import '../../core/constants/endpoints.dart';
//
// void main() {
//   runApp(const MaterialApp(home: DashboardHome()));
// }
//
//
//
// // Dashboard Home Page
// class DashboardHome extends StatelessWidget {
//   const DashboardHome({super.key});
//
//   List<Map<String, dynamic>> get teachers => [
//     {
//       'name': 'Dr. Aisha Khan',
//       'qualification': 'PhD in Physics',
//       'subjects': 'Physics, Chemistry',
//       'ranking': 1,
//       'rating': 4.8,
//       'imageUrl': "${Endpoints.domain}/assets/mobile-app/asit-t.png",
//     },
//     {
//       'name': 'Mr. John Mathew',
//       'qualification': 'MSc Mathematics',
//       'subjects': 'Maths, Statistics',
//       'ranking': 2,
//       'rating': 4.5,
//       'imageUrl': "${Endpoints.domain}/assets/mobile-app/asit-t.png",
//     },
//     {
//       'name': 'Ms. Priya Sharma',
//       'qualification': 'B.Ed English',
//       'subjects': 'English, Literature',
//       'ranking': 3,
//       'rating': 4.7,
//       'imageUrl': "${Endpoints.domain}/assets/mobile-app/asit-t.png",
//     },
//     {
//       'name': 'Mr. Rahul Menon',
//       'qualification': 'MSc Biology',
//       'subjects': 'Biology, Botany',
//       'ranking': 4,
//       'rating': 4.4,
//       'imageUrl': "${Endpoints.domain}/assets/mobile-app/asit-t.png",
//     },
//     {
//       'name': 'Mrs. Neha Varma',
//       'qualification': 'M.Ed Science',
//       'subjects': 'Science, Physics',
//       'ranking': 5,
//       'rating': 4.9,
//       'imageUrl': "${Endpoints.domain}/assets/mobile-app/asit-t.png",
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Dashboard Home")),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             TeacherCarouselTwoRows(teachers: teachers),
//             const SizedBox(height: 20),
//             // Add more dashboard widgets below
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Teacher Carousel 2 Rows
// class TeacherCarouselTwoRows extends StatelessWidget {
//   final List<Map<String, dynamic>> teachers;
//
//   const TeacherCarouselTwoRows({super.key, required this.teachers});
//
//   @override
//   Widget build(BuildContext context) {
//     // Split teachers into chunks of 2 (2 rows per page)
//     List<List<Map<String, dynamic>>> chunks = [];
//     for (var i = 0; i < teachers.length; i += 2) {
//       chunks.add(teachers.sublist(
//           i, i + 2 > teachers.length ? teachers.length : i + 2));
//     }
//
//     return CarouselSlider.builder(
//       itemCount: chunks.length,
//       options: CarouselOptions(
//         autoPlay: true,
//         enlargeCenterPage: true,
//         viewportFraction: 0.75, // peek next slide
//         height: 400, // total height for 2 stacked cards
//       ),
//       itemBuilder: (context, index, realIndex) {
//         final chunk = chunks[index];
//         return Column(
//           children: chunk.map((t) {
//             return Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: TeacherProfileCard(
//                   name: t['name'],
//                   qualification: t['qualification'],
//                   subjects: t['subjects'],
//                   ranking: t['ranking'],
//                   rating: t['rating'],
//                   imageUrl: t['imageUrl'],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
//
// // Teacher Profile Card
// class TeacherProfileCard extends StatelessWidget {
//   final String name;
//   final String qualification;
//   final String subjects;
//   final int ranking;
//   final double rating;
//   final String imageUrl;
//
//   const TeacherProfileCard({
//     super.key,
//     required this.name,
//     required this.qualification,
//     required this.subjects,
//     required this.ranking,
//     required this.rating,
//     required this.imageUrl,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Main card
//           Positioned(
//             top: 25,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: 130,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(9),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 4,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Teacher image (top-right)
//           Positioned(
//             right: -2,
//             top: -4,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 imageUrl,
//                 width: 110,
//                 height: 160,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Name
//           Positioned(
//             left: 10,
//             top: 30,
//             child: Text(
//               name,
//               style: const TextStyle(
//                 fontFamily: 'Arial',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           // Qualification
//           Positioned(
//             left: 10,
//             top: 55,
//             child: Text(
//               qualification,
//               style: const TextStyle(
//                 fontFamily: 'Arial',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 10,
//                 color: Color(0xFF3AB769),
//               ),
//             ),
//           ),
//           // Subjects
//           Positioned(
//             left: 10,
//             top: 70,
//             child: Text(
//               subjects,
//               style: const TextStyle(
//                 fontFamily: 'Arial',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 10,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           // Ranking
//           Positioned(
//             left: 10,
//             top: 90,
//             child: Text(
//               "Rank: $ranking",
//               style: const TextStyle(
//                 fontFamily: 'Arial',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 10,
//                 color: Color(0xFFEABD6C),
//               ),
//             ),
//           ),
//           // Student Rating text
//           const Positioned(
//             left: 10,
//             top: 110,
//             child: Text(
//               "Student Rating:",
//               style: TextStyle(
//                 fontFamily: 'Arial',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 10,
//                 color: Color(0xFF979797),
//               ),
//             ),
//           ),
//           // Stars
//           Positioned(
//             left: 10,
//             top: 125,
//             child: Row(
//               children: List.generate(
//                 5,
//                     (index) => Icon(
//                   index < rating.round() ? Icons.star : Icons.star_border,
//                   color: Colors.amber,
//                   size: 12,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
