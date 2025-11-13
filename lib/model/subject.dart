class Subject {
  final String name;
  final String description;
  final String mainImage;
  final String image;
  final List<Review> reviews;
  final List<Teacher> teachers;

  Subject({
    required this.name,
    required this.description,
    required this.mainImage,
    required this.image,
    required this.reviews,
    required this.teachers,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      description: json['description'] ?? '',
      mainImage: json['main_image'] ?? '',
      image: json['image'] ?? '',
      reviews: (json['reviews'] as List)
          .map((r) => Review.fromJson(r))
          .toList(),
      teachers: (json['available_teachers'] as List)
          .map((t) => Teacher.fromJson(t))
          .toList(),
    );
  }

  String get shortDescription =>
      description.length > 100 ? '${description.substring(0, 100)}...' : description;
}

class Review {
  final String name;
  final String avatar;
  final String comment;
  final int rating;

  Review({
    required this.name,
    required this.avatar,
    required this.comment,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'],
      avatar: json['avatar'],
      comment: json['comment'],
      rating: json['rating'],
    );
  }
}

class Teacher {
  final String name;
  final String qualification;
  final String experience;
  final double ranking;
  final double rating;
  final String profileImage;

  Teacher({
    required this.name,
    required this.qualification,
    required this.experience,
    required this.ranking,
    required this.rating,
    required this.profileImage,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      name: json['name'],
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? '',
      ranking: (json['ranking'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      profileImage: json['profile_image'] ?? '',
    );
  }
}
