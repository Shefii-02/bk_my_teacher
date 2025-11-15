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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        showLiveFullscreenButton: false,
        autoPlay: true,
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
            progressIndicatorColor: Colors.redAccent,
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
                    "Recorded Class Video",
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

  @override
  void initState() {

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        isLive: false,
        hideControls: true,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _controller),
        builder: (context, player) {
          return Column(
            children: [
              player,
              Center(
                child: IconButton(
                  onPressed: () {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  },
                  icon: _controller.value.isPlaying ? Icon(Icons.pause_rounded, size: 48) : Icon(Icons.play_arrow_rounded, size: 48),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(_controller.metadata.title,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("By: ${_controller.metadata.author}"),
                      ),
                    ],
                  )
              ),
            ],
          );
        },
    );
  }
}