
import 'package:BookMyTeacher/core/constants/chat_constants.dart';
import 'package:BookMyTeacher/presentation/chating/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef MessageCallback     = void Function(MessageModel msg);
typedef TypingCallback      = void Function(int convId, int userId, String name, bool typing);
typedef StatusCallback      = void Function(int userId, bool isOnline);
typedef ReadReceiptCallback = void Function(int convId, int userId);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  // Callbacks — set these before calling connect()
  MessageCallback?     onNewMessage;
  TypingCallback?      onTypingChange;
  StatusCallback?      onUserStatus;
  ReadReceiptCallback? onMessagesRead;

  // ── Connect ────────────────────────────────────────────────
  void connect( String token) {
    if (_socket != null && _socket!.connected) return; // already connected

    _socket = IO.io(
      AppConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
      // ✅ Pass token so server middleware can verify via Laravel
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('[Socket] Connected ✅');
    });

    _socket!.on('new_message', (data) {
      print('!!!!!!');
      try {
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
        onNewMessage?.call(msg);
        print('!!!------!!!');
      } catch (e) {
        print('[Socket] new_message parse error: $e');
      }
    });

    _socket!.on('typing_start', (data) {
      onTypingChange?.call(
        data['conversationId'] as int,
        data['userId']         as int,
        data['userName']       as String? ?? '',
        true,
      );
    });

    _socket!.on('typing_stop', (data) {
      onTypingChange?.call(
        data['conversationId'] as int,
        data['userId']         as int,
        '',
        false,
      );
    });

    _socket!.on('user_status', (data) {
      onUserStatus?.call(
        data['userId']   as int,
        data['isOnline'] == true,
      );
    });

    _socket!.on('messages_read', (data) {
      onMessagesRead?.call(
        data['conversationId'] as int,
        data['userId']         as int,
      );
    });

    _socket!.onDisconnect((_) => print('[Socket] Disconnected'));
    _socket!.onError((e)      => print('[Socket] Error: $e'));
  }

  // ── Join a conversation room ───────────────────────────────
  // ✅ FIX: must be called when entering a ChatScreen so the server
  //   adds this socket to "conv_<id>" — otherwise new_message never arrives.
  void joinConversation(int conversationId) {
    _socket?.emit('join', conversationId);
  }

  // ── Send message ──────────────────────────────────────────
  void sendMessage({
    required int    conversationId,
    required String messageType,
    String?  content,
    String?  fileUrl,
    String?  fileName,
    int?     fileSize,
    int?     durationSec,
    Function(Map)? onAck,
  }) {
    print('sending');
    _socket?.emitWithAck(
      'send_message',
      {
        'conversationId': conversationId,
        'messageType':    messageType,
        'content':        content,
        'fileUrl':        fileUrl,
        'fileName':       fileName,
        'fileSize':       fileSize,
        'durationSec':    durationSec,
      },
      ack: onAck,
    );
  }

  // ── Typing ─────────────────────────────────────────────────
  void sendTypingStart(int convId, String userName) {
    _socket?.emit('typing_start', {
      'conversationId': convId,
      'userName':       userName,
    });
  }

  void sendTypingStop(int convId) {
    _socket?.emit('typing_stop', {'conversationId': convId});
  }

  // ── Mark read ─────────────────────────────────────────────
  void markRead(int conversationId) {
    _socket?.emit('mark_read', {'conversationId': conversationId});
  }

  // ── Disconnect ────────────────────────────────────────────
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}