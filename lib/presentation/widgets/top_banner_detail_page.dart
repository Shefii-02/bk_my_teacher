import 'dart:ui';
import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:BookMyTeacher/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../components/shimmer_image.dart';
import '../students/providers/top_banner_provider.dart';
import '../../services/api_service.dart';

class TopBannerDetailPage extends ConsumerStatefulWidget {
  final String bannerId;

  const TopBannerDetailPage({super.key, required this.bannerId});

  @override
  ConsumerState<TopBannerDetailPage> createState() =>
      _TopBannerDetailPageState();
}

class _TopBannerDetailPageState extends ConsumerState<TopBannerDetailPage> {
  bool _isSubmitting = false;
  bool _alreadySubmitted = false;

  Future<void> _submitRequest(String bannerId) async {
    if (_alreadySubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already submitted request.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService().requestTopBannerSection(bannerId);

      if (response != null && response['status'] == true) {
        setState(() => _alreadySubmitted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Submission failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(topBannerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: bannersAsync.when(
        data: (banners) {
          final banner = banners.firstWhere(
                (b) => b.id.toString() == widget.bannerId,
            orElse: () => throw Exception('Banner not found'),
          );

          _alreadySubmitted = banner.isBooked;

          return Stack(
            children: [
              // 🔹 Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Banner Image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: ShimmerImage(
                            imageUrl: banner.mainImage,
                            width: double.infinity,
                            height: 300,
                            borderRadius: 0,
                          ),
                        ),

                        // 🔹 Back Button (Blur)
                        Positioned(
                          top: 50,
                          left: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter:
                              ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  // borderRadius: BorderRadius.only(topLeft:Radius.30),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () async {
                                    final box =
                                    await Hive.openBox('app_storage');
                                    final userId = box.get('user_id') ?? '';
                                    if (context.mounted) {
                                      context.go(
                                        AppRoutes.studentDashboard,
                                        extra: {'studentId': userId},
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        banner.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Description
                    SizedBox(
                      height: 450,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Text(
                                // banner.description ?? '',
                                "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..', comes from a line in section 1.10.32. The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from 'de Finibus Bonorum et Malorum' by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.",
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 30,)
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              // 🔹 Fixed Bottom Action Button
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _alreadySubmitted
                          ? Colors.grey
                          : Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => _submitRequest(widget.bannerId),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _alreadySubmitted
                          ? 'Already Submitted'
                          : (banner.ctaLabel.isNotEmpty
                          ? banner.ctaLabel
                          : 'Join Now'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
