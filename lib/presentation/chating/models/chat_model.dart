class ChatModel {
  final int id;
  final String name;
  final String lastMessage;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'] ?? "Chat",
      lastMessage: json['last_message'] ?? "",
    );
  }
}