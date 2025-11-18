class CourseReviewResponse {
  final List<CourseReviewModel> courses;

  CourseReviewResponse({required this.courses});

  factory CourseReviewResponse.fromJson(Map<String, dynamic> json) {
    return CourseReviewResponse(
      courses: (json["courses"] as List)
          .map((e) => CourseReviewModel.fromJson(e))
          .toList(),
    );
  }
}

class CourseReviewModel {
  final int courseId;
  final String courseName;
  final double averageRating;
  final int totalReviews;
  final List<StudentReview> reviews;

  CourseReviewModel({
    required this.courseId,
    required this.courseName,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory CourseReviewModel.fromJson(Map<String, dynamic> json) {
    return CourseReviewModel(
      courseId: json["course_id"],
      courseName: json["course_name"],
      averageRating: json["average_rating"].toDouble(),
      totalReviews: json["total_reviews"],
      reviews: (json["reviews"] as List)
          .map((e) => StudentReview.fromJson(e))
          .toList(),
    );
  }
}

class StudentReview {
  final String name;
  final double rating;
  final String comment;
  final String date;

  StudentReview({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory StudentReview.fromJson(Map<String, dynamic> json) {
    return StudentReview(
      name: json["name"] ?? '',
      rating: json["rating"].toDouble() ?? 0.0,
      comment: json["comment"] ?? '',
      date: json["date"] ?? '',
    );
  }
}
