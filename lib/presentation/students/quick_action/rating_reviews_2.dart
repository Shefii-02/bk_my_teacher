// import 'package:flutter/material.dart';
//
// class RatingsReviewsSheet extends StatefulWidget {
//   const RatingsReviewsSheet({super.key});
//
//   @override
//   State<RatingsReviewsSheet> createState() => _RatingsReviewsSheetState();
// }
//
// class _RatingsReviewsSheetState extends State<RatingsReviewsSheet> {
//   // Dummy review data
//   // final Map<String, List<Map<String, dynamic>>> courseReviews = {
//   //   "Flutter Basics": [
//   //     {"student": "Alice", "rating": 5.0, "comment": "Excellent!", "date": "Nov 10"},
//   //     {"student": "Bob", "rating": 4.0, "comment": "Very helpful", "date": "Nov 11"},
//   //   ],
//   //   "Laravel Advanced": [
//   //     {"student": "Charlie", "rating": 4.5, "comment": "Good explanations", "date": "Nov 12"},
//   //     {"student": "David", "rating": 4.0, "comment": "Learned a lot", "date": "Nov 13"},
//   //   ],
//   // };
//
//
//   // API Converted Data
//   Map<String, List<Map<String, dynamic>>> courseReviews;
//
//   String selectedCourse = "Flutter Basics";
//
//   double getAverageRating(String course) {
//     final reviews = courseReviews[course]!;
//     return reviews.map((e) => e['rating'] as double).reduce((a, b) => a + b) / reviews.length;
//   }
//
//   int getTotalReviews(String course) {
//     return courseReviews[course]?.length ?? 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final totalRating = getAverageRating(selectedCourse);
//     final totalReviews = getTotalReviews(selectedCourse);
//
//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.85,
//       minChildSize: 0.4,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: ListView(
//             controller: scrollController,
//             children: [
//               const Center(
//                 child: Text(
//                   "⭐ Ratings & Reviews",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // Dropdown to select course
//               DropdownButton<String>(
//                 value: selectedCourse,
//                 isExpanded: true,
//                 items: courseReviews.keys
//                     .map((course) => DropdownMenuItem(
//                   value: course,
//                   child: Text(course),
//                 ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCourse = value!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 12),
//
//               // Summary Cards
//               Row(
//                 children: [
//                   Expanded(
//                     child: Card(
//                       color: Colors.blueAccent,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           children: [
//                             const Text(
//                               "Total Rating",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               totalRating.toStringAsFixed(1),
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Card(
//                       color: Colors.orangeAccent,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           children: [
//                             const Text(
//                               "Total Reviews",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "$totalReviews",
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Reviews List using your container style
//               ...courseReviews[selectedCourse]!.map((review) {
//                 return _buildStudentReview(
//                   review['student'],
//                   review['comment'],
//                   review['rating'],
//                 );
//               }).toList(),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStudentReview(String name, String review, double rating) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       width: MediaQuery.of(context).size.width * 0.7,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: Colors.blueAccent,
//                 child: Text(
//                   name[0],
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Row(
//                       children: List.generate(
//                         5,
//                             (index) => Icon(
//                           index < rating ? Icons.star : Icons.star_border,
//                           color: Colors.amber,
//                           size: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             review,
//             style: const TextStyle(fontSize: 12, color: Colors.black87),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
// }
