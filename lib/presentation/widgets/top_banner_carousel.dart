import 'package:BookMyTeacher/presentation/widgets/top_banner_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../model/top_banner.dart';
import '../components/course_detail_bottom_sheet.dart';
import '../components/webinar_detail_bottom_sheet.dart';
import '../components/workshop_detail_bottom_sheet.dart';
import '../students/providers/top_banner_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/shimmer_banner.dart';

class TopBannerCarousel extends ConsumerWidget {
  const TopBannerCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBanners = ref.watch(topBannerProvider);

    return asyncBanners.when(
      data: (banners) {
        if (banners.isEmpty) {
          return const Center(child: Text('No banners found'));
        }

        return CarouselSlider.builder(
          itemCount: banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = banners[index];

            return GestureDetector(
              onTap: () {
                switch (banner.type) {
                  case 'webinar':
                    _showWebinarDetail(context, banner);
                    break;

                  case 'workshop':
                    _showWorkshopDetail(context, banner);
                    break;

                  case 'course':
                    _showCourseDetail(context, banner);
                    break;

                  default:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TopBannerDetailPage(
                          bannerId: banner.id.toString(),
                        ),
                      ),
                    );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child:
                banner.thumb != '' ?
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: banner.thumb,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (context, url) => const BannerShimmer(),
                    errorWidget: (context, url, error) => Container(
                      height: 130,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                )
                  // ClipRRect(
                //   child: Image.network(
                //     banner.thumb,
                //     fit: BoxFit.contain,
                //     width: double.infinity,
                //   ),
                // )
                    : SizedBox(),
              ),
            );
          },
          options: CarouselOptions(
            height: 130,
            viewportFraction: 0.87,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration:
            const Duration(milliseconds: 800),
            enableInfiniteScroll: true,
          ),
        );
      },
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  // ================= Bottom Sheets =================

  void _showCourseDetail(BuildContext context, banner) {
    final courseMap = banner.toCourseMap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourseDetailBottomSheet(
        course: courseMap, // or banner.course
        redirectTo: '/student-course-store',
      ),
    );
  }

  void _showWebinarDetail(BuildContext context, banner) {
    final courseMap = banner.toCourseMap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WebinarDetailBottomSheet(
        course: courseMap,
        redirectTo: '/student-course-store',
      ),
    );
  }

  void _showWorkshopDetail(BuildContext context,banner) {
    final courseMap = banner.toCourseMap();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkshopDetailBottomSheet(
        course:  courseMap,
        redirectTo: '/student-course-store',
      ),
    );
  }
}
