import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class StudentReviewsScrollSection extends StatefulWidget {
  const StudentReviewsScrollSection({super.key});

  @override
  State<StudentReviewsScrollSection> createState() => _StudentReviewsScrollSectionState();
}

class _StudentReviewsScrollSectionState extends State<StudentReviewsScrollSection> {
  Widget _buildStudentReview(String name, String review, String image, double rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
            blurStyle: BlurStyle.outer,
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
                backgroundImage: NetworkImage(image),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> studentReviews = [
      {
        "name": "Aisha Patel",
        "review": "Great teacher! Explained concepts very clearly.",
        "image": "https://i.pravatar.cc/150?img=5",
        "rating": 4.5,
      },
      {
        "name": "Rahul Sharma",
        "review": "Helpful and patient during sessions.",
        "image": "https://i.pravatar.cc/150?img=12",
        "rating": 5.0,
      },
      {
        "name": "Sneha R.",
        "review": "Good teaching but classes sometimes run late.",
        "image": "https://i.pravatar.cc/150?img=8",
        "rating": 3.5,
      },
      {
        "name": "Kevin Thomas",
        "review": "Very friendly and made learning fun!",
        "image": "https://i.pravatar.cc/150?img=14",
        "rating": 4.0,
      },
      {
        "name": "Aisha Patel-1",
        "review": "Great teacher! Explained concepts very clearly.",
        "image": "https://i.pravatar.cc/150?img=5",
        "rating": 4.5,
      },
      {
        "name": "Rahul Sharma-2",
        "review": "Helpful and patient during sessions.",
        "image": "https://i.pravatar.cc/150?img=12",
        "rating": 5.0,
      },
      {
        "name": "Sneha R.-3",
        "review": "Good teaching but classes sometimes run late.",
        "image": "https://i.pravatar.cc/150?img=8",
        "rating": 3.5,
      },
      {
        "name": "Kevin Thomas-4",
        "review": "Very friendly and made learning fun!",
        "image": "https://i.pravatar.cc/150?img=14",
        "rating": 4.0,
      },
      {
        "name": "Rahul Sharma-5",
        "review": "Helpful and patient during sessions.",
        "image": "https://i.pravatar.cc/150?img=12",
        "rating": 5.0,
      },
      {
        "name": "Sneha R.-6",
        "review": "Good teaching but classes sometimes run late.",
        "image": "https://i.pravatar.cc/150?img=8",
        "rating": 3.5,
      },
      {
        "name": "Kevin Thomas-7",
        "review": "Very friendly and made learning fun!",
        "image": "https://i.pravatar.cc/150?img=14",
        "rating": 4.0,
      },
    ];

    // Split list into chunks of 2
    final List<List<Map<String, dynamic>>> reviewPairs = [];
    for (int i = 0; i < studentReviews.length; i += 2) {
      reviewPairs.add(studentReviews.sublist(
        i,
        i + 2 > studentReviews.length ? studentReviews.length : i + 2,
      ));
    }

    int _currentPage = 0;
    return Column(
      children: [
        Container(
          height: 280, // enough height for 2 cards vertically
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: CarouselSlider.builder(
            itemCount: reviewPairs.length,
            options: CarouselOptions(
              height: 360,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              viewportFraction: 0.8,
              autoPlay: true,
              pageSnapping: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                  });
                }
            ),
            itemBuilder: (context, index, realIdx) {
              final pair = reviewPairs[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pair.map((r) {
                  return _buildStudentReview(
                    r['name'],
                    r['review'],
                    r['image'],
                    r['rating'],
                  );
                }).toList(),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(reviewPairs.length > 5 ? 4 : reviewPairs.length, (index) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blue : Colors.grey,
              ),
            );
          }),
        )
      ],
    );

    return SizedBox(
      height: 280, // enough height for 2 cards vertically
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reviewPairs.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final pair = reviewPairs[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: pair.map((r) {
                return _buildStudentReview(
                  r['name'],
                  r['review'],
                  r['image'],
                  r['rating'],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
