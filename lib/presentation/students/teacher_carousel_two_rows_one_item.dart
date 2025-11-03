import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// 2 rows x 2 columns carousel
class TeacherCarouselTwoRowsTwoColumns extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;

  const TeacherCarouselTwoRowsTwoColumns({super.key, required this.teachers});

  @override
  Widget build(BuildContext context) {
    // Split teachers into chunks of 4 (2 rows x 2 cols)
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
        viewportFraction: 0.85,
        height: 350,
      ),
      itemBuilder: (context, index, realIndex) {
        final chunk = chunks[index];
        return Column(
          children: [
            // First row
            Row(
              children: List.generate(
                2,
                    (i) {
                  if (i < chunk.length) {
                    final t = chunk[i];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
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
                  } else {
                    return const Expanded(child: SizedBox());
                  }
                },
              ),
            ),
            // Second row
            Row(
              children: List.generate(
                2,
                    (i) {
                  if (i + 2 < chunk.length) {
                    final t = chunk[i + 2];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
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
                  } else {
                    return const Expanded(child: SizedBox());
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Teacher Profile Card (simplified)
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
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imageUrl, width: 70, height: 70),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(qualification, style: const TextStyle(fontSize: 12)),
          Text(subjects, style: const TextStyle(fontSize: 12)),
          Text("Rank: $ranking"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
                  (index) => Icon(
                index < rating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}