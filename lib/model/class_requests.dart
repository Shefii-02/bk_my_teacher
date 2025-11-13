class ClassRequest {
  final int id;
  final String title;
  final String grade;
  final String board;
  final String subject;
  final String note;
  final String status;
  final String createdAt;

  ClassRequest({
    required this.id,
    required this.title,
    required this.grade,
    required this.board,
    required this.subject,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  factory ClassRequest.fromJson(Map<String, dynamic> json) {
    return ClassRequest(
      id: json['id'],
      title: json['title'],
      grade: json['grade'],
      board: json['board'],
      subject: json['subject'],
      note: json['note'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
