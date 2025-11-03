// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
//
// import 'teacher_profile_card.dart'; // <-- your existing card file
//
// class TeacherCarousel extends StatelessWidget {
//   final List<Map<String, dynamic>> teachers;
//
//   const TeacherCarousel({super.key, required this.teachers});
//
//   @override
//   Widget build(BuildContext context) {
//     // Each page will show 4 cards (2 columns × 2 rows)
//     final List<List<Map<String, dynamic>>> pages = [];
//     for (int i = 0; i < teachers.length; i += 4) {
//       pages.add(teachers.sublist(
//         i,
//         i + 4 > teachers.length ? teachers.length : i + 4,
//       ));
//     }
//
//     return CarouselSlider(
//       options: CarouselOptions(
//         height: 380,
//         autoPlay: true,
//         enlargeCenterPage: true,
//         viewportFraction: 1,
//         enableInfiniteScroll: false,
//       ),
//       items: pages.map((pageTeachers) {
//         return Builder(
//           builder: (context) {
//             return GridView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // 2 per row
//                 childAspectRatio: 1.2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//               ),
//               itemCount: pageTeachers.length,
//               itemBuilder: (context, index) {
//                 final t = pageTeachers[index];
//                 return TeacherProfileCard(
//                   name: t['name'],
//                   qualification: t['qualification'],
//                   subjects: t['subjects'],
//                   ranking: t['ranking'],
//                   rating: t['rating'],
//                   imageUrl: t['imageUrl'],
//                 );
//               },
//             );
//           },
//         );
//       }).toList(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TeacherCarousel extends StatelessWidget {
  const TeacherCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> teachers = [
      {
        "name": "Asif T",
        "qualification": "NET Qualified",
        "subjects": "Computer Science, English",
        "ranking": 1,
        "rating": 5.0,
        "image":
        "https://via.placeholder.com/150x150.png?text=Asif+T",
      },
      {
        "name": "Rahul K",
        "qualification": "PhD Scholar",
        "subjects": "Physics, Chemistry",
        "ranking": 2,
        "rating": 4.8,
        "image":
        "https://via.placeholder.com/150x150.png?text=Rahul+K",
      },
      {
        "name": "Sneha P",
        "qualification": "M.Sc Mathematics",
        "subjects": "Mathematics",
        "ranking": 3,
        "rating": 4.7,
        "image":
        "https://via.placeholder.com/150x150.png?text=Sneha+P",
      },
      {
        "name": "Amina V",
        "qualification": "M.Ed, NET",
        "subjects": "Biology",
        "ranking": 4,
        "rating": 4.9,
        "image":
        "https://via.placeholder.com/150x150.png?text=Amina+V",
      },
    ];

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Top Teachers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Carousel Section
          SizedBox(
            width: double.infinity,
            height: 250,
            child: CarouselSlider.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index, realIndex) {
                final t = teachers[index];
                return _TeacherProfileCard(
                  name: t['name'],
                  qualification: t['qualification'],
                  subjects: t['subjects'],
                  ranking: t['ranking'],
                  rating: t['rating'],
                  imageUrl: t['image'],
                );
              },
              options: CarouselOptions(
                height: 250,
                viewportFraction: 0.65,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enableInfiniteScroll: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherProfileCard extends StatelessWidget {
  final String name;
  final String qualification;
  final String subjects;
  final int ranking;
  final double rating;
  final String imageUrl;

  const _TeacherProfileCard({
    required this.name,
    required this.qualification,
    required this.subjects,
    required this.ranking,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Card background
        Container(
          margin: const EdgeInsets.only(top: 60, left: 8, right: 8, bottom: 8),
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name.length > 5 ? "${name.substring(0, 5)}.." : name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                qualification,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subjects,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Rank #$ranking",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile Image Overlay
        Positioned(
          top: 0,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

