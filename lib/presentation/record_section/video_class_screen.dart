
import 'dart:async';
import 'dart:convert';

import 'package:BookMyTeacher/presentation/record_section/record_screen_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_section.dart';
import 'chat_tab.dart';
import 'doubt_tab.dart';
import 'poll_tab.dart';

// ─── CONSTANTS ───────────────────────────────────────────────────────────────
const String kBaseUrl   = 'https://your-api.example.com';    // ← change
const String kSocketUrl = 'https://your-socket.example.com'; // ← change

// ─── SCREEN ──────────────────────────────────────────────────────────────────

class VideoClassScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String classId;
  final String type; // 'course' | 'webinar' | 'workshop'

  const VideoClassScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    required this.classId,
    required this.type,
  });

  @override
  State<VideoClassScreen> createState() => _VideoClassScreenState();
}

class _VideoClassScreenState extends State<VideoClassScreen>
    with SingleTickerProviderStateMixin {
  // ── Video ──
  late YoutubePlayerController _yt;
  bool _videoReady = false;
  bool _isPlaying  = false;
  bool _isMuted    = false;
  bool _isMini     = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _uiTimer;

  // ── Tabs ──
  late TabController _tabController;
  int _activeTab = 0;

  // ── Chat ──
  IO.Socket? _socket;
  final List<ChatMessage> _messages    = [];
  final TextEditingController _chatCtrl   = TextEditingController();
  final ScrollController      _chatScroll = ScrollController();
  bool _socketConnected = false;
  final String _myUserId = 'me';
  final String _myName   = 'You';

  // ── Doubt ──
  final TextEditingController _doubtCtrl = TextEditingController();
  bool _submittingDoubt = false;
  final List<String> _myDoubts = [];

  // ── Poll ──
  Poll? _poll;
  bool _loadingPoll = true;

  // ── Loading overlay ──
  bool _showLoader = true;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() => _activeTab = _tabController.index));

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
    _initPlayer(videoId);
    _initSocket();
    _fetchPoll();

    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showLoader = false);
    });
  }

  // ── Player ──────────────────────────────────────────────────────────────────

  void _initPlayer(String videoId) {
    _yt = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        hideControls: true,
        loop: false,
        disableDragSeek: false,
        enableCaption: false,
        showLiveFullscreenButton: false,
      ),
    );

    _uiTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || !_yt.value.isReady) return;
      setState(() {
        _position   = _yt.value.position;
        _duration   = _yt.metadata.duration;
        _isPlaying  = _yt.value.isPlaying;
        _videoReady = true;
      });
    });
  }

  void _togglePlay() => _isPlaying ? _yt.pause() : _yt.play();

  void _toggleMute() {
    _isMuted ? _yt.unMute() : _yt.mute();
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _seek(int seconds) async {
    _yt.pause();
    await Future.delayed(const Duration(milliseconds: 400));
    final target = _position + Duration(seconds: seconds);
    _yt.seekTo(target.isNegative ? Duration.zero : target);
    _yt.play();
  }

  // ── Socket ───────────────────────────────────────────────────────────────────

  void _initSocket() {
    _socket = IO.io(
      kSocketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      setState(() => _socketConnected = true);
      _socket!.emit('join_room', {'class_id': widget.classId});
    });

    _socket!.onDisconnect((_) =>
        setState(() => _socketConnected = false));

    _socket!.on('chat_message', (data) {
      final msg = ChatMessage.fromJson(
        Map<String, dynamic>.from(data),
        isMe: data['user_id']?.toString() == _myUserId,
      );
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });

    _socket!.on('chat_history', (data) {
      final list = (data as List<dynamic>)
          .map((d) => ChatMessage.fromJson(
        Map<String, dynamic>.from(d),
        isMe: d['user_id']?.toString() == _myUserId,
      ))
          .toList();
      setState(() {
        _messages.clear();
        _messages.addAll(list);
      });
      _scrollToBottom();
    });

    _socket!.on('poll_update', (data) {
      if (_poll == null) return;
      final updated = Map<String, dynamic>.from(data);
      setState(() {
        for (var opt in _poll!.options) {
          opt.votes =
              (updated['votes']?[opt.id] as num?)?.toInt() ?? opt.votes;
        }
        _poll!.totalVotes =
            _poll!.options.fold(0, (s, o) => s + o.votes);
      });
    });
  }

  void _sendChat() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty || !_socketConnected) return;
    _socket!.emit('chat_message', {
      'class_id': widget.classId,
      'user_id': _myUserId,
      'sender': _myName,
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _chatCtrl.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Poll ─────────────────────────────────────────────────────────────────────

  Future<void> _fetchPoll() async {
    try {
      final res = await http.get(
          Uri.parse('$kBaseUrl/api/classes/${widget.classId}/poll'));
      if (res.statusCode == 200) {
        setState(() {
          _poll = Poll.fromJson(jsonDecode(res.body));
          _loadingPoll = false;
        });
      } else {
        setState(() => _loadingPoll = false);
      }
    } catch (_) {
      setState(() => _loadingPoll = false);
    }
  }

  Future<void> _votePoll(String optionId) async {
    if (_poll == null || _poll!.myVoteId != null) return;
    setState(() => _poll!.myVoteId = optionId);

    for (var o in _poll!.options) {
      if (o.id == optionId) o.votes++;
    }
    _poll!.totalVotes++;

    _socket?.emit('poll_vote', {
      'class_id': widget.classId,
      'poll_id': _poll!.id,
      'option_id': optionId,
      'user_id': _myUserId,
    });

    try {
      await http.post(
        Uri.parse('$kBaseUrl/api/classes/${widget.classId}/poll/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'option_id': optionId}),
      );
    } catch (_) {}
  }

  // ── Doubt ────────────────────────────────────────────────────────────────────

  Future<void> _submitDoubt() async {
    final text = _doubtCtrl.text.trim();
    if (text.isEmpty || _submittingDoubt) return;
    setState(() => _submittingDoubt = true);

    try {
      final endpoint = widget.type == 'course'
          ? '$kBaseUrl/api/course-classes/${widget.classId}/doubts'
          : widget.type == 'webinar'
          ? '$kBaseUrl/api/webinar-classes/${widget.classId}/doubts'
          : '$kBaseUrl/api/workshop-classes/${widget.classId}/doubts';

      await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'doubt': text}),
      );

      setState(() {
        _myDoubts.insert(0, text);
        _doubtCtrl.clear();
      });
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _submittingDoubt = false);
    }
  }

  // ── Dispose ──────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _uiTimer?.cancel();
    _yt.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    _tabController.dispose();
    _chatCtrl.dispose();
    _doubtCtrl.dispose();
    _chatScroll.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── AppBar ────────────────────────────────────────────────
                _AppBar(
                  title: widget.title,
                  isMini: _isMini,
                  onToggleMini: () => setState(() => _isMini = !_isMini),
                ),

                // ── Video Player ──────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  height: _isMini
                      ? 90
                      : MediaQuery.of(context).size.width * 9 / 16,
                  child: VideoSection(
                    controller: _yt,
                    isPlaying: _isPlaying,
                    isMuted: _isMuted,
                    isMini: _isMini,
                    position: _position,
                    duration: _duration,
                    videoReady: _videoReady,
                    onTogglePlay: _togglePlay,
                    onToggleMute: _toggleMute,
                    onSeekForward: () => _seek(30),
                    onSeekBackward: () => _seek(-30),

                    onSeekTo: (v) async => {
                      _yt.pause(),
                      await Future.delayed(const Duration(milliseconds: 400)),
                      _yt.seekTo(Duration(seconds: v.toInt())),
                      _yt.play(),
                    },
                    onFullscreen: () {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                      _yt.toggleFullScreenMode();
                    },
                  ),
                ),

                // ── Tab Bar ───────────────────────────────────────────────
                _ClassTabBar(
                  controller: _tabController,
                  socketConnected: _socketConnected,
                ),

                // ── Tab Views ─────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ChatTab(
                        messages: _messages,
                        scrollController: _chatScroll,
                        chatCtrl: _chatCtrl,
                        connected: _socketConnected,
                        onSend: _sendChat,
                      ),
                      DoubtTab(
                        ctrl: _doubtCtrl,
                        doubts: _myDoubts,
                        submitting: _submittingDoubt,
                        onSubmit: _submitDoubt,
                      ),
                      PollTab(
                        poll: _poll,
                        loading: _loadingPoll,
                        onVote: _votePoll,
                        onRefresh: _fetchPoll,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Loading Overlay ───────────────────────────────────────────
            if (_showLoader)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F0F13),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading class...',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── APP BAR ─────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final String title;
  final bool isMini;
  final VoidCallback onToggleMini;

  const _AppBar({
    required this.title,
    required this.isMini,
    required this.onToggleMini,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF16161D),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─── TAB BAR ─────────────────────────────────────────────────────────────────

class _ClassTabBar extends StatelessWidget {
  final TabController controller;
  final bool socketConnected;

  const _ClassTabBar(
      {required this.controller, required this.socketConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF16161D),
      child: TabBar(
        controller: controller,
        labelColor: const Color(0xFF6C63FF),
        unselectedLabelColor: Colors.white38,
        indicatorColor: const Color(0xFF6C63FF),
        indicatorWeight: 2.5,
        labelStyle:
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                const SizedBox(width: 4),
                const Text('Live Chat'),
                const SizedBox(width: 4),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: socketConnected
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded, size: 15),
                SizedBox(width: 4),
                Text('Doubts'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.poll_outlined, size: 15),
                SizedBox(width: 4),
                Text('Poll'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}