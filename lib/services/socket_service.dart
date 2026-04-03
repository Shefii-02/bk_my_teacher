//
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../core/app_theme.dart';
// import '../presentation/chating/models/conversation_model.dart';
//
//
// typedef MessageCallback       = void Function(MessageModel);
// typedef TypingCallback        = void Function(int convId, int userId, String name, bool typing);
// typedef StatusCallback        = void Function(int userId, bool isOnline);
// typedef ReadReceiptCallback   = void Function(int convId, List<int> msgIds, int userId);
//
// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();
//
//   IO.Socket? _socket;
//   bool get isConnected => _socket?.connected ?? false;
//
//   // Callbacks
//   MessageCallback?     onNewMessage;
//   TypingCallback?      onTypingChange;
//   StatusCallback?      onUserStatus;
//   ReadReceiptCallback? onMessagesRead;
//
//   void connect(String url, int userId) {
//     _socket = IO.io(url, IO.OptionBuilder()
//         .setTransports(['websocket'])
//         .disableAutoConnect()
//         .build());
//
//     _socket!.connect();
//
//     _socket!.onConnect((_) {
//       print('[Socket] Connected');
//       _socket!.emit('user_online', {'userId': userId});
//     });
//
//     _socket!.on('new_message', (data) {
//       final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
//       onNewMessage?.call(msg);
//     });
//
//     _socket!.on('typing_start', (data) {
//       onTypingChange?.call(
//           data['conversationId'], data['userId'], data['userName'] ?? '', true
//       );
//     });
//
//     _socket!.on('typing_stop', (data) {
//       onTypingChange?.call(data['conversationId'], data['userId'], '', false);
//     });
//
//     _socket!.on('user_status', (data) {
//       onUserStatus?.call(data['userId'], data['isOnline'] == true);
//     });
//
//     _socket!.on('messages_read', (data) {
//       final ids = List<int>.from(data['messageIds']);
//       onMessagesRead?.call(data['conversationId'], ids, data['userId']);
//     });
//
//     _socket!.onDisconnect((_) => print('[Socket] Disconnected'));
//     _socket!.onError((e)      => print('[Socket] Error: $e'));
//   }
//
//   void sendMessage({
//     required int    conversationId,
//     required int    senderId,
//     required String messageType,
//     String?  content,
//     String?  fileUrl,
//     String?  fileName,
//     int?     fileSize,
//     int?     durationSec,
//     Function(Map)? onAck,
//   }) {
//     print('started');
//     _socket?.emitWithAck('send_message', {
//       'conversationId': conversationId,
//       'senderId':       senderId,
//       'messageType':    messageType,
//       'content':        content,
//       'fileUrl':        fileUrl,
//       'fileName':       fileName,
//       'fileSize':       fileSize,
//       'durationSec':    durationSec,
//     }, ack: onAck);
//     print('ended');
//   }
//
//   void markRead(int conversationId, int userId) {
//     _socket?.emit('mark_read', {'conversationId': conversationId, 'userId': userId});
//   }
//
//   void sendTypingStart(int convId, int userId, String userName) {
//     _socket?.emit('typing_start', {
//       'conversationId': convId, 'userId': userId, 'userName': userName
//     });
//   }
//
//   void sendTypingStop(int convId, int userId) {
//     _socket?.emit('typing_stop', {'conversationId': convId, 'userId': userId});
//   }
//
//   void disconnect() {
//     _socket?.disconnect();
//     _socket?.dispose();
//     _socket = null;
//   }
// }