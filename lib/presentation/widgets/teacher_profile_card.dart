import 'package:flutter/material.dart';

class TeacherProfileCard extends StatelessWidget {
  final String name;
  final String qualification;
  final String subjects;
  final int ranking;
  final double rating;
  final String imageUrl;
  final VoidCallback? onTap; // ✅ add this

  const TeacherProfileCard({
    super.key,
    required this.name,
    required this.qualification,
    required this.subjects,
    required this.ranking,
    required this.rating,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ make entire card tappable
      onTap: onTap,
      child: SizedBox(
        height: 150,
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
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
      ),
    );
  }
}
