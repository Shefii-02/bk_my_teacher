// lib/model/message_model.dart

enum MessageType { text, image, pdf, audio, unknown }

class MessageModel {
  final int         id;
  final int         conversationId;   // ✅ FIX 6: was missing — needed to filter in socket
  final int         senderId;
  final String?     content;
  final String?     fileUrl;
  final String?     fileName;
  final int?        fileSize;
  final int?        durationSec;
  final MessageType messageType;
  final String      status;           // sent | delivered | seen
  final DateTime    createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.durationSec,
    required this.messageType,
    this.status = 'sent',
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:             json['id']              as int? ?? 0,
      conversationId: json['conversation_id'] as int? ?? 0,   // ✅ FIX 6
      senderId:       json['sender_id']       as int? ?? 0,
      content:        json['content']         as String?,
      fileUrl:        json['file_url']        as String?,
      fileName:       json['file_name']       as String?,
      fileSize:       json['file_size']       as int?,
      durationSec:    json['duration_sec']    as int?,
      messageType:    _parseType(json['message_type'] as String?),
      status:         json['status']          as String? ?? 'sent',
      createdAt:      DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static MessageType _parseType(String? type) {
    switch (type) {
      case 'text':  return MessageType.text;
      case 'image': return MessageType.image;
      case 'pdf':   return MessageType.pdf;
      case 'voice':
      case 'audio': return MessageType.audio;
      default:      return MessageType.unknown;
    }
  }

  /// Formatted file size string (e.g. "1.2 MB")
  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024)       return '${fileSize} B';
    if (fileSize! < 1048576)    return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / 1048576).toStringAsFixed(1)} MB';
  }

  bool isMe(int myId) => senderId == myId;
}