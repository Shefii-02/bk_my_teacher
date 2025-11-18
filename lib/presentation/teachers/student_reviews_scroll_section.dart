import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../model/student_review.dart';
import '../../services/teacher_api_service.dart';

class StudentReviewsScrollSection extends StatefulWidget {
  const StudentReviewsScrollSection({super.key});

  @override
  State<StudentReviewsScrollSection> createState() => _StudentReviewsScrollSectionState();
}

class _StudentReviewsScrollSectionState extends State<StudentReviewsScrollSection> {
  // CORRECTED: Use StudentReviewMain consistently
  List<StudentReviewMain> studentReviews = [];
  bool loading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final data = await TeacherApiService().fetchMainReviews();
    setState(() {
      studentReviews = data;
      loading = false;
    });
  }

  Widget _buildStudentReview(StudentReviewMain r) {
    // CORRECTED: Uncommented the image and review text, fixed rating logic.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(16),
      // Adjusted width for better fit, maybe 90% is better for the column layout
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white, // Changed to white/light color for visibility
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // A more standard box shadow for a card effect
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            // UNCOMMENTED: Added CircleAvatar back
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(r.image),
              // Fallback for missing image
              onBackgroundImageError: (exception, stackTrace) => const Text('?'),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: const TextStyle(fontSize:13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                // CORRECTED: Logic to handle double rating (e.g., 4.5 stars)
                Row(children: List.generate(5, (i) {
                  // i is 0 to 4. Full stars if rating is >= i+1. Half star if rating is between i and i+1.
                  if (r.rating >= i + 1) {
                    return const Icon(Icons.star, color: Colors.amber, size: 14);
                  } else if (r.rating > i && r.rating < i + 1) {
                    return const Icon(Icons.star_half, color: Colors.amber, size: 14);
                  } else {
                    return const Icon(Icons.star_border, color: Colors.amber, size: 14);
                  }
                }))
              ],
            )),
          ]),
          const SizedBox(height: 6),
          // UNCOMMENTED: Added review text back
          Text(r.review, style: const TextStyle(fontSize:12, color: Colors.black87), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Split into list of pairs of 2 items
    final reviewPairs = <List<StudentReviewMain>>[];
    for (int i = 0; i < studentReviews.length; i += 2) {
      reviewPairs.add(studentReviews.sublist(
        i,
        i + 2 > studentReviews.length ? studentReviews.length : i + 2,
      ));
    }

    if (reviewPairs.isEmpty) {
      return const Center(child: Text('No reviews available.'));
    }

    return Column(
      children: [
        // Main slider for pairs
        Container(
          // CORRECTED: Reduced height to better fit two cards (assuming card height ~120-130)
          height: 280,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: CarouselSlider.builder(
            itemCount: reviewPairs.length,
            options: CarouselOptions(
              // CORRECTED: Set height closer to the container height
              height: 256,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              // CORRECTED: Adjusted viewportFraction for better visibility in a single column
              viewportFraction: 0.9,
              autoPlay: true,
              pageSnapping: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            itemBuilder: (context, index, realIdx) {
              final pair = reviewPairs[index];
              return Column(
                // Ensure a little space between the two review cards
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: pair.map((r) => _buildStudentReview(r)).toList(),
              );
            },
          ),
        ),

        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(reviewPairs.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blue : Colors.grey.withOpacity(0.5),
              ),
            );
          }),
        ),
      ],
    );
  }
}