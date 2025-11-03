import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../model/top_banner.dart';
import '../students/providers/top_banner_provider.dart';

class TopBannerCarousel extends ConsumerWidget {
  const TopBannerCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBanners = ref.watch(topBannerProvider);

    return asyncBanners.when(
      data: (banners) {
        if (banners.isEmpty) return const Center(child: Text('No banners found'));

        return CarouselSlider.builder(
          itemCount: banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = banners[index];
            return GestureDetector(
              onTap: () {
                // if (banner.ctaAction.isNotEmpty) {
                //   context.push(banner.ctaAction); // e.g., /register
                // }
                GoRouter.of(context).go('/top-banner/${banner.id}');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    banner.mainImage,
                    fit: BoxFit.contain, // preserves original aspect ratio
                    width: double.infinity,
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 130, // adjust as needed
            viewportFraction: 0.87, // shows a little part of next slide
            // enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enableInfiniteScroll: true, // infinite loop
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
