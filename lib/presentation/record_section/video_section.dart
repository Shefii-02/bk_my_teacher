// ─── video_section.dart ───────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ── YoutubeNoLogo ─────────────────────────────────────────────────────────────
/// Wraps YoutubePlayer and covers YouTube branding with black overlays.

class YoutubeNoLogo extends StatelessWidget {
  final YoutubePlayerController controller;
  const YoutubeNoLogo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayerBuilder(
          player: YoutubePlayer(controller: controller),
          builder: (ctx, player) =>
              Container(color: Colors.black, child: player),
        ),
        // Top bar — channel name / title
        // Positioned(
        //   top: 0, left: 0, right: 0,
        //   child: Container(height: 30, color: Colors.black),
        // ),
        // // Bottom-left — YouTube logo
        // Positioned(
        //   bottom: 0, left: 0,
        //   child: Container(width: 80, height: 32, color: Colors.black),
        // ),
        // // Bottom-right — "Watch on YouTube" button
        // Positioned(
        //   bottom: 0, right: 0,
        //   child: Container(width: 80, height: 32, color: Colors.black),
        // ),
      ],
    );
  }
}

// ── VideoSection ──────────────────────────────────────────────────────────────

class VideoSection extends StatefulWidget {
  final YoutubePlayerController controller;
  final bool isPlaying, isMuted, isMini, videoReady;
  final Duration position, duration;
  final VoidCallback onTogglePlay, onToggleMute, onSeekForward,
      onSeekBackward, onFullscreen;
  final ValueChanged<double> onSeekTo;

  const VideoSection({
    super.key,
    required this.controller,
    required this.isPlaying,
    required this.isMuted,
    required this.isMini,
    required this.videoReady,
    required this.position,
    required this.duration,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onFullscreen,
    required this.onSeekTo,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  bool _showOverlay = true;
  Timer? _overlayTimer;

  void _handleTap() {
    setState(() => _showOverlay = true);
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3),
            () { if (mounted) setState(() => _showOverlay = false); });
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final totalSec =
    widget.duration.inSeconds.toDouble().clamp(1.0, double.infinity);
    final currentSec =
    widget.position.inSeconds.toDouble().clamp(0.0, totalSec);

    // ── Full Player ────────────────────────────────────────────────────────────
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          YoutubeNoLogo(controller: widget.controller),

          AnimatedOpacity(
            opacity: _showOverlay ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: widget.onToggleMute,
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen_rounded,
                            color: Colors.white, size: 22),
                        onPressed: widget.onFullscreen,
                      ),
                    ],
                  ),

                  // center buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CtrlBtn(
                          icon: Icons.replay_30_rounded,
                          onTap: widget.onSeekBackward),
                      const SizedBox(width: 28),
                      GestureDetector(
                        onTap: widget.onTogglePlay,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF)
                                    .withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      _CtrlBtn(
                          icon: Icons.forward_30_rounded,
                          onTap: widget.onSeekForward),
                    ],
                  ),

                  // bottom seek bar + time labels
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, bottom: 6),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2.5,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white
                                .withOpacity(0.2),
                            showValueIndicator: ShowValueIndicator.never,
                          ),
                          child: Slider(
                            value: currentSec,
                            max: totalSec,
                            // onChanged: widget.onSeekTo,
                            onChanged: (value) {
                              widget.onSeekTo(value);
                            },
                            onChangeEnd: widget.onSeekTo,
                          ),
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(widget.position),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11)),
                            Text(_fmt(widget.duration),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _CtrlBtn ──────────────────────────────────────────────────────────────────

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: Colors.white, size: 32),
  );
}