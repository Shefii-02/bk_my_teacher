// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
//
// class AwsIvsLivePlayer extends StatefulWidget {
//   const AwsIvsLivePlayer({super.key});
//
//   @override
//   State<AwsIvsLivePlayer> createState() => _AwsIvsLivePlayerState();
// }
//
// class _AwsIvsLivePlayerState extends State<AwsIvsLivePlayer> {
//   late VideoPlayerController _controller;
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     // AWS IVS Playback URL
//     const liveUrl =
//         'https://your-channel-playback-url.m3u8'; // From AWS Console
//
//     _controller = VideoPlayerController.networkUrl(Uri.parse(liveUrl))
//       ..initialize().then((_) {
//         _chewieController = ChewieController(
//           videoPlayerController: _controller,
//           autoPlay: true,
//           allowFullScreen: true,
//           allowPlaybackSpeedChanging: false,
//         );
//         setState(() {});
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('AWS IVS Live')),
//       body: Center(
//         child: _chewieController != null &&
//             _controller.value.isInitialized
//             ? Chewie(controller: _chewieController!)
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
// }
