enum MessageType { text, image, pdf, audio }

class MessageModel {
  final String id;
  final String senderId;
  final String message;
  final String? fileUrl;
  final MessageType type;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.message,
    this.fileUrl,
    required this.type,
    required this.createdAt,
  });
}
