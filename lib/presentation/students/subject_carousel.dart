import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../core/constants/endpoints.dart';
// -------------------- Subject Carousel 3x3 --------------------
class SubjectCarousel extends StatelessWidget {
  const SubjectCarousel({super.key});

  final List<Map<String, String>> subjects = const [
    {'name': 'English', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Math', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Science', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'History', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Geography', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Art', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Physics', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Chemistry', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Biology', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'English-9', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Math-8', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Science-7', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'History-6', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Geography-5', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Art-4', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Physics-3', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Chemistry-2', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
    {'name': 'Biology-1', 'image': "${Endpoints.domain}/assets/mobile-app/icons/book-icon.png"},
  ];

  @override
  Widget build(BuildContext context) {
    // Split subjects into chunks of 9 (3x3 per slide)
    List<List<Map<String, String>>> slides = [];
    for (var i = 0; i < subjects.length; i += 9) {
      slides.add(
        subjects.sublist(
          i,
          i + 9 > subjects.length ? subjects.length : i + 9,
        ),
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

  const SubjectCard({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          Positioned(
            left: 7,
            top: 20,
            width: 35.3,
            height: 22.98,
            child: Image.network(image, fit: BoxFit.contain),
          ),
          Positioned(
            left: 45,
            top: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name.length > 5 ? "${name.substring(0, 5)}.." : name,
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
                )
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
    );
  }
}

