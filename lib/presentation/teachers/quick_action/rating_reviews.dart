import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/teacher_reviews_provider.dart';

class RatingsReviewsSheet extends ConsumerStatefulWidget {
  const RatingsReviewsSheet({super.key});

  @override
  ConsumerState<RatingsReviewsSheet> createState() => _RatingsReviewsSheetState();
}

class _RatingsReviewsSheetState extends ConsumerState<RatingsReviewsSheet> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncReviews = ref.watch(teacherReviewsProvider);

    return asyncReviews.when(
      loading: () => const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (response) {
        final courses = response.courses;
        final selected = courses[selectedIndex];

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  const Center(
                    child: Text(
                      "⭐ Ratings & Reviews",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // COURSE DROPDOWN
                  DropdownButton<int>(
                    value: selectedIndex,
                    isExpanded: true,
                    items: List.generate(
                      courses.length,
                          (i) => DropdownMenuItem(
                        value: i,
                        child: Text(courses[i].courseName),
                      ),
                    ),
                    onChanged: (value) => setState(() => selectedIndex = value!),
                  ),

                  const SizedBox(height: 12),

                  // SUMMARY CARDS
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.blueAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text("Average Rating", style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(
                                  selected.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: Colors.orangeAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text("Total Reviews", style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(
                                  "${selected.totalReviews}",
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // REVIEWS LIST
                  ...selected.reviews.map((r) => _buildStudentReview(r.name, r.comment, r.rating)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentReview(String name, String review, double rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent,
                child: Text(name[0], style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: List.generate(
                    5,
                        (i) => Icon(i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(review, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}
