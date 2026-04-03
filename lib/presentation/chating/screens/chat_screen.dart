// lib/screens/chat_screen.dart

import 'dart:async';
import 'dart:io';

import 'package:BookMyTeacher/presentation/chating/models/conversation_model.dart';
import 'package:BookMyTeacher/presentation/chating/models/message_model.dart';
import 'package:BookMyTeacher/presentation/chating/services/chat_api.dart';
import 'package:BookMyTeacher/presentation/chating/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/app_theme.dart';
import '../../../services/launch_status_service.dart';



class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  final String            token;
  final int?               currentUserId = 69;  // ✅ FIX: no more hardcoded 69

   const ChatScreen({
    super.key,
    required this.conversation,
    required this.token,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl      = TextEditingController();
  final _scrollCtrl    = ScrollController();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer   = AudioPlayer();

  List<MessageModel> _messages   = [];
  bool   _loading        = true;
  bool   _sending        = false;
  bool   _isRecording    = false;
  bool   _hasMore        = true;
  int    _offset         = 0;
  String? _recordPath;
  int    _recordSeconds  = 0;
  Timer? _recordTimer;

  bool   _otherTyping  = false;
  String _typingName   = '';
  Timer? _typingTimer;
  bool   _isMeTyping   = false;

  Map<int, bool>   _playingMap  = {};
  String?          _currentPlayingUrl;

  int get _myId => 69;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupSocket();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _recordTimer?.cancel();
    _typingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── Socket setup ──────────────────────────────────────────
  void _setupSocket() {
    final socket = SocketService();

    // ✅ FIX: join the conversation room so new_message arrives
    socket.joinConversation(widget.conversation.id);

    socket.onNewMessage = (msg) {
      // ✅ FIX: filter by conversation_id, not msg.id
      if (msg.conversationId == widget.conversation.id && mounted) {
        setState(() => _messages.insert(0, msg));
        _scrollToBottom();
      }
    };

    socket.onTypingChange = (convId, userId, name, typing) {
      if (convId == widget.conversation.id &&
          userId != _myId &&
          mounted) {
        setState(() { _otherTyping = typing; _typingName = name; });
      }
    };

    // Mark as read when opening the screen
    socket.markRead(widget.conversation.id);
  }

  // ── Load messages (paginated) ─────────────────────────────
  Future<void> _loadMessages({bool loadMore = false}) async {
    if (!_hasMore && loadMore) return;

    try {
      final msgs = await ChatApiService().getMessages(
        widget.conversation.id,
        widget.token,
        offset: loadMore ? _offset : 0,
      );

      setState(() {
        if (loadMore) {
          _messages.addAll(msgs); // already in DESC order from server
        } else {
          _messages = msgs;
          _offset   = 0;
        }
        _offset  += msgs.length;
        _hasMore  = msgs.length == 30;
        _loading  = false;
      });

      if (!loadMore) _scrollToBottom();
    } catch (e) {
      print("LOAD ERROR: $e");
      setState(() => _loading = false);
    }
  }

  void _onScroll() {
    // reverse:true → old messages are at bottom (maxScrollExtent)
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 50 &&
        _hasMore &&
        !_loading) {
      _loadMessages(loadMore: true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Typing detection ──────────────────────────────────────
  void _onTextChanged(String v) {
    if (v.isNotEmpty && !_isMeTyping) {
      _isMeTyping = true;
      SocketService().sendTypingStart(
        widget.conversation.id,
        'Me', // replace with real user name if available
      );
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isMeTyping) {
        _isMeTyping = false;
        SocketService().sendTypingStop(widget.conversation.id);
      }
    });
  }

  // ── Send text ─────────────────────────────────────────────
  void _sendText() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    _textCtrl.clear();
    _isMeTyping = false;
    SocketService().sendTypingStop(widget.conversation.id);

    SocketService().sendMessage(
      conversationId: widget.conversation.id,
      messageType:    'text',
      content:        text,
    );
  }

  // ── Pick & upload file ────────────────────────────────────
  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'pdf' ? ['pdf'] : ['doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.first.path!);
    setState(() => _sending = true);
    try {
      final uploaded = await ChatApiService().uploadFile(file);
      SocketService().sendMessage(
        conversationId: widget.conversation.id,
        messageType:    type,
        fileUrl:        uploaded['url'],
        fileName:       uploaded['originalName'],
        fileSize:       uploaded['size'],
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  // ── Voice recording ───────────────────────────────────────
  Future<void> _startRecording() async {
    final permitted = await _audioRecorder.hasPermission();
    if (!permitted) return;

    final dir   = await getTemporaryDirectory();
    _recordPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: _recordPath!,
    );

    setState(() { _isRecording = true; _recordSeconds = 0; });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordSeconds++);
    });
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    _recordTimer?.cancel();
    await _audioRecorder.stop();
    setState(() => _isRecording = false);

    if (cancel || _recordPath == null) return;

    final file = File(_recordPath!);
    if (!await file.exists()) return;

    setState(() => _sending = true);
    try {
      final uploaded = await ChatApiService().uploadFile(file);
      SocketService().sendMessage(
        conversationId: widget.conversation.id,
        messageType:    'voice',
        fileUrl:        uploaded['url'],
        fileName:       'Voice message',
        fileSize:       uploaded['size'],
        durationSec:    _recordSeconds,
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  // ── Voice playback ────────────────────────────────────────
  Future<void> _toggleVoicePlay(MessageModel msg) async {
    final url = msg.fileUrl!;
    if (_currentPlayingUrl == url) {
      await _audioPlayer.pause();
      setState(() { _playingMap[msg.id] = false; _currentPlayingUrl = null; });
    } else {
      if (_currentPlayingUrl != null) {
        await _audioPlayer.stop();
        _playingMap.updateAll((_, __) => false);
      }
      await _audioPlayer.play(UrlSource(url));
      setState(() { _playingMap[msg.id] = true; _currentPlayingUrl = url; });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() { _playingMap[msg.id] = false; _currentPlayingUrl = null; });
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(conv),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _buildMessageList(),
          ),
          if (_otherTyping) _TypingIndicator(name: _typingName),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ConversationModel conv) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(children: [
            _Avatar(
              name:     conv.conversationName,
              imageUrl: conv.displayAvatar,
              isGroup:  conv.type == 'group',
              size:     40,
            ),
            if (conv.type == 'direct' && conv.isOnline)
              Positioned(
                right: 1, bottom: 1,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conv.conversationName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                Text(
                  conv.type == 'group'
                      ? 'Group chat'
                      : (conv.isOnline
                      ? 'Online'
                      : (conv.otherUserLastSeen != null
                      ? 'Last seen ${timeago.format(DateTime.parse(conv.otherUserLastSeen!))}'
                      : 'Offline')),
                  style: TextStyle(
                    fontSize: 12,
                    color: conv.isOnline ? AppTheme.success : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) {
        final msg  = _messages[i];
        final isMe = msg.isMe(_myId);

        // Date divider between days
        Widget? divider;
        if (i < _messages.length - 1) {
          final curr = _messages[i].createdAt;
          final prev = _messages[i + 1].createdAt;
          if (!_sameDay(curr, prev)) {
            divider = _DateDivider(date: curr.toIso8601String());
          }
        }

        return Column(
          children: [
            if (divider != null) divider,
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(16),
                    topRight:    const Radius.circular(16),
                    bottomLeft:  Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4  : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMessageContent(msg, isMe),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputBar() {
    if (_isRecording) {
      return _RecordingBar(
        seconds:  _recordSeconds,
        onCancel: () => _stopRecording(cancel: true),
        onSend:   () => _stopRecording(),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 8, right: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(
        children: [
          _AttachButton(
            onPdf:  () => _pickFile('pdf'),
            onDocx: () => _pickFile('docx'),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textCtrl,
                onChanged:  _onTextChanged,
                maxLines: 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textCtrl,
            builder: (_, val, __) {
              final hasText = val.text.trim().isNotEmpty;
              return GestureDetector(
                onLongPress: _startRecording,
                onTap:       hasText ? _sendText : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: hasText ? AppTheme.primary : AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasText ? Icons.send : Icons.mic,
                    color: hasText ? Colors.white : AppTheme.primary,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildMessageContent(MessageModel msg, bool isMe) {
    switch (msg.messageType) {
      case MessageType.text:
        return Text(
          msg.content ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 14, height: 1.4,
          ),
        );

      case MessageType.audio:
        final isPlaying = _playingMap[msg.id] ?? false;
        return GestureDetector(
          onTap: msg.fileUrl != null ? () => _toggleVoicePlay(msg) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: isMe ? Colors.white : AppTheme.primary,
                size: 32,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice message',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  if (msg.durationSec != null)
                    Text(
                      _formatDuration(msg.durationSec!),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );

      case MessageType.pdf:
      case MessageType.unknown:
        final isPdf = msg.messageType == MessageType.pdf;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf : Icons.description,
              color: isMe ? Colors.white : (isPdf ? Colors.red : AppTheme.accent),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.fileName ?? (isPdf ? 'PDF Document' : 'Word Document'),
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (msg.fileSize != null)
                    Text(
                      msg.fileSizeFormatted,
                      style: TextStyle(
                        color: isMe ? Colors.white70 : AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      default:
        return Text(
          msg.content ?? '',
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        );
    }
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ── Date Divider ──────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final String date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    String label;
    try {
      final d   = DateTime.parse(date);
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        label = 'Today';
      } else if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMM d, yyyy').format(d);
      }
    } catch (_) { label = ''; }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ]),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final String name;
  const _TypingIndicator({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
      child: Row(children: [
        const SizedBox(width: 8),
        Text('$name is typing…',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic)),
        const SizedBox(width: 4),
        _DotsIndicator(),
      ]),
    );
  }
}

class _DotsIndicator extends StatefulWidget {
  @override State<_DotsIndicator> createState() => _DotsState();
}
class _DotsState extends State<_DotsIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState();
  _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Row(children: List.generate(3, (i) {
      final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
      return Container(
        width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withOpacity(t < 0.5 ? t * 2 : (1 - t) * 2),
          shape: BoxShape.circle,
        ),
      );
    })),
  );
}

// ── Recording bar ─────────────────────────────────────────────
class _RecordingBar extends StatelessWidget {
  final int seconds;
  final VoidCallback onCancel;
  final VoidCallback onSend;
  const _RecordingBar({required this.seconds, required this.onCancel, required this.onSend});

  String get _time {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16, right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.delete, color: AppTheme.error), onPressed: onCancel),
        const SizedBox(width: 8),
        Container(width: 10, height: 10,
            decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(_time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        const Text('Recording…', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const Spacer(),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

// ── Attach button ─────────────────────────────────────────────
class _AttachButton extends StatelessWidget {
  final VoidCallback onPdf;
  final VoidCallback onDocx;
  const _AttachButton({required this.onPdf, required this.onDocx});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) { if (v == 'pdf') onPdf(); else onDocx(); },
      icon: const Icon(Icons.attach_file, color: AppTheme.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'pdf',
            child: Row(children: [
              Icon(Icons.picture_as_pdf, color: AppTheme.error, size: 20),
              SizedBox(width: 10),
              Text('PDF Document'),
            ])),
        const PopupMenuItem(value: 'docx',
            child: Row(children: [
              Icon(Icons.description, color: AppTheme.accent, size: 20),
              SizedBox(width: 10),
              Text('Word Document'),
            ])),
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String  name;
  final String? imageUrl;
  final bool    isGroup;
  final double  size;
  const _Avatar({required this.name, this.imageUrl, this.isGroup = false, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final parts    = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isEmpty ? '?' : name[0].toUpperCase());

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isGroup
              ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
              : [AppTheme.primary, AppTheme.accent],
        ),
      ),
      child: imageUrl != null
          ? ClipOval(child: Image.network(imageUrl!, fit: BoxFit.cover))
          : Center(
          child: Text(initials,
              style: TextStyle(color: Colors.white,
                  fontSize: size * 0.35, fontWeight: FontWeight.w700))),
    );
  }
}