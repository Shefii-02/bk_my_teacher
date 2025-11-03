import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CouseSections extends StatelessWidget {
  const CouseSections({super.key});

  final List<String> images = const [
    "${Endpoints.domain}/assets/mobile-app/banners/course-banner-1.png",
    "${Endpoints.domain}/assets/mobile-app/banners/course-banner-2.png",
    "${Endpoints.domain}/assets/mobile-app/banners/course-banner-3.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CarouselSlider.builder(
        itemCount: images.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 150, // adjust height
          enlargeCenterPage: true, // center item bigger
          viewportFraction: 0.8, // show partial next item
          enableInfiniteScroll: true,
          autoPlay: true,
        ),
      ),
    );
  }
}
