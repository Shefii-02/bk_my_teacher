import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
// 2 rows x 2 columns carousel (keep original style)
class TeacherCarouselTwoRows extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;
  const TeacherCarouselTwoRows({super.key, required this.teachers});

  @override
  Widget build(BuildContext context) {
    // split into chunks of 4 teachers per slide
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < teachers.length; i += 4) {
      chunks.add(teachers.sublist(
          i, i + 4 > teachers.length ? teachers.length : i + 4));
    }

    return CarouselSlider.builder(
      itemCount: chunks.length,
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.95,
        height: 390, // enough for 2 stacked cards
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
                      name: chunk[i]['name'],
                      qualification: chunk[i]['qualification'],
                      subjects: chunk[i]['subjects'],
                      ranking: chunk[i]['ranking'],
                      rating: chunk[i]['rating'],
                      imageUrl: chunk[i]['imageUrl'],
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
                      name: chunk[i + 2]['name'],
                      qualification: chunk[i + 2]['qualification'],
                      subjects: chunk[i + 2]['subjects'],
                      ranking: chunk[i + 2]['ranking'],
                      rating: chunk[i + 2]['rating'],
                      imageUrl: chunk[i + 2]['imageUrl'],
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

// Original TeacherProfileCard style
class TeacherProfileCard extends StatelessWidget {
  final String name;
  final String qualification;
  final String subjects;
  final int ranking;
  final double rating;
  final String imageUrl;

  const TeacherProfileCard({
    super.key,
    required this.name,
    required this.qualification,
    required this.subjects,
    required this.ranking,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4)),
                ],
              ),
            ),
          ),
          Positioned(
            right: -2,
            top: 0,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  "Rank: $ranking",
                  style: const TextStyle(
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: Color(0xFFEABD6C)),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            top: 50,
            child: Text(
              name,
              style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Colors.black),
            ),
          ),
          Positioned(
            left: 10,
            top: 70,
            child: Text(
              qualification,
              style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: Color(0xFF3AB769)),
            ),
          ),
          Positioned(
            left: 10,
            top: 85,
            child: Text(
              subjects,
              style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: Colors.black),
            ),
          ),

          const Positioned(
            left: 10,
            top: 105,
            child: Text(
              "Student Rating:",
              style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: Color(0xFF979797)),
            ),
          ),
          Positioned(
            left: 10,
            top: 122,
            child: Row(
              children: List.generate(
                5,
                    (index) => Icon(
                  index < rating.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

