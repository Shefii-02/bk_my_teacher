import 'package:BookMyTeacher/presentation/students/subject_detail_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';

// -------------------- Subject Carousel 3x3 --------------------
class SubjectCarousel extends StatefulWidget {
  SubjectCarousel({super.key});

  @override
  State<SubjectCarousel> createState() => _SubjectCarouselState();
}

class _SubjectCarouselState extends State<SubjectCarousel> {
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
      debugPrint("Error loading teachers: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget build(BuildContext context) {
    // Split subjects into chunks of 9 (3x3 per slide)
    List<List<Map<String, dynamic>>> slides = [];
    for (var i = 0; i < subjects.length; i += 9) {
      slides.add(
        subjects.sublist(i, i + 9 > subjects.length ? subjects.length : i + 9),
      );
    }

    return CarouselSlider.builder(
      itemCount: slides.length,
      itemBuilder: (context, index, realIndex) {
        final slide = slides[index];
        return Column(
          children: [
            for (int row = 0; row < 3; row++)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int col = 0; col < 3; col++)
                      if (row * 3 + col < slide.length)
                        SubjectCard(
                          name: slide[row * 3 + col]['name']!,
                          image: slide[row * 3 + col]['image']!,
                          subject: slide[row * 3 + col],
                        )
                      else
                        const SizedBox(width: 103, height: 34),
                  ],
                ),
              ),
          ],
        );
      },
      options: CarouselOptions(
        height: 200, // adjust based on card size + spacing
        autoPlay: false,
        enlargeCenterPage: false,
        viewportFraction: 1.0,
      ),
    );
  }
}

// -------------------- Single Subject Card --------------------
class SubjectCard extends StatelessWidget {
  final String name;
  final String image;
  final Map<String, dynamic>? subject;

  const SubjectCard({
    super.key,
    required this.name,
    required this.image,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to subject detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailPage(subject: subject ?? {}),
          ),
        );
      },
      child: Container(
        width: 128,
        height: 50,
        margin: const EdgeInsets.all(2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Positioned(
            //   left: 7,
            //   top: 20,
            //   width: 35.3,
            //   height: 22.98,
            //   child: Image.network(image, fit: BoxFit.contain),
            // ),
            Positioned(
              // left: 45,
              left: 17,
              top: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name.length > 15 ? "${name.substring(0, 15)}.." : name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 1.2,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.black.withOpacity(0.46),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   right: 2.75,
            //   top: 10,
            //   width: 2.5,
            //   height: 4.99,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(
            //         color: Colors.black.withOpacity(0.46),
            //         width: 2,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
