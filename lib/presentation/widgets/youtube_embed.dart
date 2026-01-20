import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class YoutubeEmbed extends StatefulWidget {
  final String videoId;
  const YoutubeEmbed({super.key, required this.videoId});

  @override
  State<YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<YoutubeEmbed> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    // Force portrait orientation for video
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller =
        YoutubePlayerController(
          initialVideoId: widget.videoId,
          flags: const YoutubePlayerFlags(
            showLiveFullscreenButton: false,
            autoPlay: false,
            mute: false,
            disableDragSeek: true,
            hideControls: false,
            loop: false,
            enableCaption: false,
            forceHD: true,
            useHybridComposition: true, // For Android WebView fix
          ),
        )..addListener(() {
          if (_controller.value.isReady && !_isPlayerReady) {
            setState(() {
              _isPlayerReady = true;
            });
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Disable long press (no “Copy link”)
      onLongPress: () {},
      child: AbsorbPointer(
        absorbing: false,
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
            onReady: () => debugPrint('YouTube Player Ready!'),
            bottomActions: [
              const SizedBox(width: 8),
              CurrentPosition(),
              const SizedBox(width: 8),
              ProgressBar(isExpanded: true),
              const SizedBox(width: 8),
              RemainingDuration(),
              const SizedBox(width: 8),
            ],
          ),
          builder: (context, player) {
            return Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(aspectRatio: 16 / 9, child: player),
                  Text(
                    "Class Video Loading...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isPlayerReady)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class YouTubeVideoPlayer extends StatefulWidget {
  final String videoId;
  const YouTubeVideoPlayer({super.key, required this.videoId});

  @override
  _YouTubeVideoPlayerState createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isPlaying = false;
  bool isLoading = true;
  bool _isLoading = true;
  bool _isMuted = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Timer? _uiTimer;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
        hideControls: true,
        // forceHD: true,
        // useHybridComposition: true,
        loop: true,
        disableDragSeek: true,
        showLiveFullscreenButton: false,
      ),
    );

    /// ⏱ Update UI every 500ms
    _uiTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      if (!_controller.value.isReady) return;

      setState(() {
        _currentPosition = _controller.value.position;
        _totalDuration = _controller.metadata.duration;
        _isPlaying = _controller.value.isPlaying;
        _isLoading = false;
      });
    });

    _controller.addListener(() {
      if (!mounted) return;

      final playing = _controller.value.isPlaying;
      if (playing != _isPlaying) {
        setState(() {
          _isPlaying = playing;
        });
      }
      // if (_controller.value.isReady && isLoading) {
      //   setState(() => isLoading = false);
      // }
    });
    // ⏳ 3-second fullscreen loader
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _togglePlayPause() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
    setState(() {});
  }

  Future<void> _seekForward() async {
    _controller.pause();
    await Future.delayed(const Duration(milliseconds: 400));
    final pos = _controller.value.position;
    _controller.seekTo(pos + const Duration(seconds: 30));
    _controller.play();
  }

  Future<void> _seekBackward() async {
    _controller.pause();
    await Future.delayed(const Duration(milliseconds: 400));
    final pos = _controller.value.position;
    _controller.seekTo(pos - const Duration(seconds: 30));
    _controller.play();
  }

  void _toggleMute() {
    if (_isMuted) {
      _controller.unMute();
    } else {
      _controller.mute();
    }

    setState(() {
      _isMuted = !_isMuted;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayerBuilder(
          player: YoutubePlayer(controller: _controller),
          builder: (context, player) {
            return Column(
              children: [
                player,

                /// Dark overlay
                AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(color: Colors.black45),
                ),

                /// 🎚 SEEK BAR
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.5,

                    // ✅ Played part color
                    activeTrackColor: Colors.green,

                    // ✅ Unplayed part color
                    inactiveTrackColor: Colors.grey.shade300,

                    // ✅ Thumb color
                    thumbColor: Colors.black,

                    // ✅ Thumb ripple
                    overlayColor: Colors.red.withOpacity(0.2),

                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),

                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds
                        .clamp(0, _totalDuration.inSeconds)
                        .toDouble(),
                    max: _totalDuration.inSeconds > 0
                        ? _totalDuration.inSeconds.toDouble()
                        : 1,
                    onChanged: (value) {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22.0,
                    vertical: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(_currentPosition),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatTime(_totalDuration),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Center Controls
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _showControls ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              iconSize: 40,
                              icon: const Icon(
                                Icons.replay_30,
                                color: Colors.black,
                              ),
                              onPressed: _seekBackward,
                            ),
                            IconButton(
                              onPressed: () {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              },
                              icon: _isPlaying
                                  ? Icon(Icons.pause_circle_filled, size: 48)
                                  : Icon(Icons.play_circle_fill, size: 48),
                            ),
                            IconButton(
                              iconSize: 40,
                              icon: const Icon(
                                Icons.replay_30,
                                color: Colors.black,
                              ),
                              onPressed: _seekForward,
                            ),
                            IconButton(
                              iconSize: 28,
                              icon: Icon(
                                _isMuted ? Icons.volume_off : Icons.volume_up,
                                color: Colors.black,
                              ),
                              onPressed: _toggleMute,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _controller.toggleFullScreenMode();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        /// ⏳ FULLSCREEN LOADER OVER VIDEO
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ⏱ FORMAT mm:ss
String formatTime(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);

  String two(int n) => n.toString().padLeft(2, '0');

  if (hours > 0) {
    return "${two(hours)}:${two(minutes)}:${two(seconds)}";
  } else {
    return "${two(minutes)}:${two(seconds)}";
  }
  return "$minutes:$seconds";
}
