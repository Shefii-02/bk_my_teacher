import 'package:BookMyTeacher/presentation/students/teacher_details_page.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../widgets/teacher_profile_card.dart';

// 2 rows x 2 columns carousel (keep original style)
class TeacherCarouselTwoRows extends StatefulWidget {
  TeacherCarouselTwoRows({super.key});

  @override
  State<TeacherCarouselTwoRows> createState() => _TeacherCarouselTwoRowsState();
}

class _TeacherCarouselTwoRowsState extends State<TeacherCarouselTwoRows> {
  // final List<Map<String, dynamic>> teachers;
  List<Map<String, dynamic>> teachers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      final result = await ApiService().getTeachers();
      if (mounted) {
        setState(() {
          teachers = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading teachers: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget build(BuildContext context) {
    // split into chunks of 4 teachers per slide
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < teachers.length; i += 4) {
      chunks.add(
        teachers.sublist(i, i + 4 > teachers.length ? teachers.length : i + 4),
      );
    }

    return CarouselSlider.builder(
      itemCount: chunks.length,
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.95,
        height: 380, // enough for 2 stacked cards
      ),
      itemBuilder: (context, index, realIndex) {
        final chunk = chunks[index];
        return Column(
          children: [
            Row(
              children: List.generate(
                2,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: i < chunk.length
                        ? TeacherProfileCard(
                            name: chunk[i]['name'].length > 13
                                ? "${chunk[i]['name'].substring(0, 13)}.."
                                : chunk[i]['name'],
                            qualification: chunk[i]['qualification'].length > 13
                                ? "${chunk[i]['qualification'].substring(0, 13)}.."
                                : chunk[i]['qualification'],
                            subjects: chunk[i]['subjects'].length > 13
                                ? "${chunk[i]['subjects'].substring(0, 13)}.."
                                : chunk[i]['subjects'],
                            ranking: chunk[i]['ranking'],
                            rating: chunk[i]['rating'].toDouble(),
                            imageUrl: chunk[i]['imageUrl'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TeacherDetailsPage(teacher: chunk[i]),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
            Row(
              children: List.generate(
                2,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: (i + 2) < chunk.length
                        ? TeacherProfileCard(
                            name: chunk[i + 2]['name'].length > 13
                                ? "${chunk[i + 2]['name'].substring(0, 13)}.."
                                : chunk[i + 2]['name'],
                            qualification: chunk[i + 2]['qualification'],
                            subjects: chunk[i + 2]['subjects'],
                            ranking: chunk[i + 2]['ranking'],
                            rating: chunk[i + 2]['rating'].toDouble(),
                            imageUrl: chunk[i + 2]['imageUrl'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TeacherDetailsPage(teacher: chunk[i + 2]),
                                ),
                              );
                            },
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

