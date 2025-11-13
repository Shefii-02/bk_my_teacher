class Teacher {
  final int id;
  final String name;
  final String qualification;
  final String subjects;
  final int ranking;
  final double rating;
  final String imageUrl;

  Teacher({
    required this.id,
    required this.name,
    required this.qualification,
    required this.subjects,
    required this.ranking,
    required this.rating,
    required this.imageUrl,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
      qualification: json['qualification'],
      subjects: json['subjects'],
      ranking: json['ranking'],
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
