// lib/model/conversation_model.dart

class ConversationModel {
  final int     id;
  final String  type;
  final String? name;
  final String? avatarUrl;
  final String? lastMessage;
  final String? lastMessageType;
  final String? lastMessageTime;
  final int     unreadCount;

  final int?    otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? otherUserRole;
  final bool    otherUserOnline;
  final String? otherUserLastSeen;

  const ConversationModel({
    required this.id,
    required this.type,
    this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserRole,
    this.otherUserOnline = false,
    this.otherUserLastSeen,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> j) => ConversationModel(
    id:                j['id'],
    type:              j['type']             ?? 'direct',
    name:              j['name'],
    avatarUrl:         j['avatar_url'],
    lastMessage:       j['last_message'],
    lastMessageType:   j['last_message_type'],
    lastMessageTime:   j['last_message_time'],
    unreadCount:       j['unread_count']     ?? 0,
    otherUserId:       j['other_user_id'],
    otherUserName:     j['other_user_name'],
    otherUserAvatar:   j['other_user_avatar'],
    otherUserRole:     j['other_user_role'],
    otherUserOnline:   j['other_user_online'] == 1 || j['other_user_online'] == true,
    otherUserLastSeen: j['other_user_last_seen'],
  );

  String  get displayName       => type == 'group' ? (name ?? 'Group') : (otherUserName ?? 'Unknown');
  String? get displayAvatar     => type == 'group' ? avatarUrl : otherUserAvatar;
  bool    get isOnline          => type == 'direct' && otherUserOnline;
  String  get conversationName  => type == 'group' ? (name ?? 'Group') : (otherUserName ?? 'Unknown');
}