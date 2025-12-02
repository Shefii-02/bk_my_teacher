// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
//
// class MuxVideoPlayer extends StatefulWidget {
//   const MuxVideoPlayer({super.key});
//
//   @override
//   State<MuxVideoPlayer> createState() => _MuxVideoPlayerState();
// }
//
// class _MuxVideoPlayerState extends State<MuxVideoPlayer> {
//   late VideoPlayerController _videoController;
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     // Example Mux HLS URL (replace playback_id with your own)
//     const videoUrl = 'https://stream.mux.com/YOUR_PLAYBACK_ID.m3u8';
//
//     _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
//       ..initialize().then((_) {
//         _chewieController = ChewieController(
//           videoPlayerController: _videoController,
//           autoPlay: true,
//           looping: false,
//           aspectRatio: _videoController.value.aspectRatio,
//         );
//         setState(() {});
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mux Player')),
//       body: Center(
//         child: _chewieController != null &&
//             _videoController.value.isInitialized
//             ? Chewie(controller: _chewieController!)
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _videoController.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
// }
