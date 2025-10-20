import 'package:flutter/material.dart';

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
      width: 179,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          Positioned(
            top: 25,
            left: 0,
            child: Container(
              width: 200,
              height: 85,
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
            left: 130,
            top: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 71.4,
                height: 108,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Name
          const Positioned(
            left: 8,
            top: 34,
            child: Text(
              "ASIF T",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.6,
                color: Colors.black,
              ),
            ),
          ),

          // Qualification
          const Positioned(
            left: 8,
            top: 55,
            child: Text(
              "NET Qualified",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Color(0xFF3AB769),
              ),
            ),
          ),

          // Subjects
          const Positioned(
            left: 9,
            top: 70,
            child: Text(
              "Computer Science, English",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 5,
                color: Colors.black,
              ),
            ),
          ),

          // Ranking
          Positioned(
            left: 87,
            top: 32,
            child: Text(
              "Rank: $ranking",
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 6,
                color: Color(0xFFEABD6C),
              ),
            ),
          ),

          // Student Rating text
          const Positioned(
            left: 10,
            top: 85,
            child: Text(
              "Student Rating:",
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
                fontSize: 6,
                color: Color(0xFF979797),
              ),
            ),
          ),

          // Stars
          Positioned(
            left: 10,
            top: 95,
            child: Row(
              children: List.generate(
                5,
                    (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
