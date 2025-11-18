class StudentReviewMain {
  final String name;
  final String review;
  final String image;
  final double rating;

  StudentReviewMain({
    required this.name,
    required this.review,
    required this.image,
    required this.rating,
  });

  factory StudentReviewMain.fromJson(Map<String, dynamic> json) {
    return StudentReviewMain(
      name: json['name'] ?? "",
      review: json['review'] ?? "",
      image: json['image'] ?? "",
      // Ensure rating is parsed as a double
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
    );
  }
}