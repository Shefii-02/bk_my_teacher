class StudentModel {
  final int id;
  final String name;
  final String? email;
  final String? city;
  final String? state;
  final String? country;

  StudentModel({
    required this.id,
    required this.name,
    this.email,
    this.city,
    this.state,
    this.country,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }
}
