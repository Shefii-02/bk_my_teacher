import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../core/constants/endpoints.dart';

// Teacher Profile Card
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
      width: double.infinity,
      height: 180, // Adjusted height to fit 2 cards in carousel
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Teacher image (top-right)
          Positioned(
            right: 10,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Name
          Positioned(
            left: 10,
            top: 30,
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          // Qualification
          Positioned(
            left: 10,
            top: 55,
            child: Text(
              qualification,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Color(0xFF3AB769),
              ),
            ),
          ),
          // Subjects
          Positioned(
            left: 10,
            top: 70,
            child: Text(
              subjects,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ),
          // Ranking
          Positioned(
            left: 10,
            top: 90,
            child: Text(
              "Rank: $ranking",
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Color(0xFFEABD6C),
              ),
            ),
          ),
          // Student Rating text
          const Positioned(
            left: 10,
            top: 110,
            child: Text(
              "Student Rating:",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Color(0xFF979797),
              ),
            ),
          ),
          // Stars
          Positioned(
            left: 10,
            top: 125,
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

// 2-row Carousel
class TeacherCarouselTwoRows extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;

  const TeacherCarouselTwoRows({super.key, required this.teachers});

  @override
  Widget build(BuildContext context) {
    // Split teachers into chunks of 2 (2 rows per page)
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < teachers.length; i += 2) {
      chunks.add(teachers.sublist(
          i, i + 2 > teachers.length ? teachers.length : i + 2));
    }

    return CarouselSlider.builder(
      itemCount: chunks.length,
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.75,
        height: 400, // total height for 2 stacked cards
      ),
      itemBuilder: (context, index, realIndex) {
        final chunk = chunks[index];
        return Column(
          children: chunk.map((t) {
            return Expanded( // <-- Use Expanded
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TeacherProfileCard(
                  name: t['name'],
                  qualification: t['qualification'],
                  subjects: t['subjects'],
                  ranking: t['ranking'],
                  rating: t['rating'],
                  imageUrl: t['imageUrl'],
                ),
              ),
            );
          }).toList(),
        );
      },
    );

  }
}
