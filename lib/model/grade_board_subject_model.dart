class Grade {
  final int id;
  final String name;
  final List<Board> boards;

  Grade({
    required this.id,
    required this.name,
    required this.boards,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      boards: (json['boards'] as List<dynamic>)
          .map((b) => Board.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => name;
}

class Board {
  final int id;
  final String name;
  final List<Subject> subjects;

  Board({
    required this.id,
    required this.name,
    required this.subjects,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subjects: (json['subjects'] as List<dynamic>)
          .map((s) => Subject.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => name;
}

class Subject {
  final int id;
  final String name;

  Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  String toString() => name;
}
