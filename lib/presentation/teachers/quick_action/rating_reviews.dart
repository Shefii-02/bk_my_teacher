import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/teacher_reviews_provider.dart';

class RatingsReviewsSheet extends ConsumerStatefulWidget {
  const RatingsReviewsSheet({super.key});

  @override
  ConsumerState<RatingsReviewsSheet> createState() =>
      _RatingsReviewsSheetState();
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

        // Handle empty courses safely
        if (courses.isEmpty) {
          return SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.menu_book, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No courses or reviews available",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Ensure selectedIndex is valid
        if (selectedIndex >= courses.length) selectedIndex = 0;
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  const Center(
                    child: Text(
                      "⭐ Ratings & Reviews",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // COURSE DROPDOWN
                  DropdownButton<int>(
                    value: selectedIndex,
                    isExpanded: true,
                    items: List.generate(
                      courses.length,
                          (i) => DropdownMenuItem(
                        value: i,
                        child: Text(
                          courses[i].courseName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedIndex = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // SUMMARY CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "Average Rating",
                          value: selected.averageRating.toStringAsFixed(1),
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: "Total Reviews",
                          value: "${selected.totalReviews}",
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // REVIEWS LIST
                  if (selected.reviews.isEmpty)
                    const Center(
                      child: Text(
                        "No reviews available for this course",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                    ...selected.reviews
                        .map((r) => _buildStudentReview(r.name, r.comment, r.rating)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryCard({required String title, required String value, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentReview(String name, String review, double rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
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
                child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(i < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.isNotEmpty ? review : "No comment",
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
