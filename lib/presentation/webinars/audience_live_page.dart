import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class AudienceLivePage extends StatelessWidget {
  final int appID;
  final String appSign;
  final String userID;
  final String userName;
  final String liveID;
  final bool isHost;
  final String title;
  final String hostName;

  const AudienceLivePage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    this.isHost = false,
    this.title = '',
    this.hostName = '',
  });

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       // 1️⃣ Background gradient
    //       Container(
    //         decoration: const BoxDecoration(
    //           gradient: LinearGradient(
    //             colors: [Colors.deepPurple, Colors.black87],
    //             begin: Alignment.topCenter,
    //             end: Alignment.bottomCenter,
    //           ),
    //         ),
    //       ),
    //
    //       // 2️⃣ Live streaming widget
    //       ZegoUIKitPrebuiltLiveStreaming(
    //         appID: appID,
    //         appSign: appSign,
    //         userID: userID,
    //         userName: userName,
    //         liveID: liveID,
    //         config: isHost
    //             ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
    //             : ZegoUIKitPrebuiltLiveStreamingConfig.audience()
    //           ..useSpeakerWhenJoining = true,
    //       ),
    //
    //       // 3️⃣ Top overlay: webinar title & host
    //       Positioned(
    //         top: 20,
    //         left: 16,
    //         right: 16,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.center,
    //                 children: [
    //                   Text(
    //                     title,
    //                     style: const TextStyle(
    //                       color: Colors.white,
    //                       fontSize: 20,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //
    //                 ],
    //               ),
    //             ),
    //
    //           ],
    //         ),
    //       ),
    //
    //       // 4️⃣ Floating mic / speaker buttons (example)
    //       // Positioned(
    //       //   bottom: 100,
    //       //   right: 16,
    //       //   child: Column(
    //       //     children: [
    //       //       FloatingActionButton(
    //       //         heroTag: 'mic',
    //       //         mini: true,
    //       //         backgroundColor: Colors.white.withOpacity(0.8),
    //       //         onPressed: () {},
    //       //         child: const Icon(Icons.mic, color: Colors.black87),
    //       //       ),
    //       //       const SizedBox(height: 12),
    //       //       FloatingActionButton(
    //       //         heroTag: 'speaker',
    //       //         mini: true,
    //       //         backgroundColor: Colors.white.withOpacity(0.8),
    //       //         onPressed: () {},
    //       //         child: const Icon(Icons.volume_up, color: Colors.black87),
    //       //       ),
    //       //     ],
    //       //   ),
    //       // ),
    //
    //       // 5️⃣ Bottom overlay: chat toggle + reactions
    //       Positioned(
    //         bottom: 20,
    //         left: 16,
    //         right: 16,
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.end,
    //           children: [
    //
    //             ElevatedButton.icon(
    //               onPressed: () {},
    //               icon: const Icon(Icons.thumb_up, size: 18),
    //               label: const Text('React'),
    //               style: ElevatedButton.styleFrom(
    //                 backgroundColor: Colors.white.withOpacity(0.2),
    //                 foregroundColor: Colors.white,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Text('');
  }
}

// class AudienceLivePage extends StatelessWidget {
//   final int appID;
//   final String appSign;
//   final String userID;
//   final String userName;
//   final String liveID;
//   final bool isHost;
//   final String title;
//   final String hostName;
//
//   const AudienceLivePage({
//     super.key,
//     required this.appID,
//     required this.appSign,
//     required this.userID,
//     required this.userName,
//     required this.liveID,
//     this.isHost = false,
//     this.title = '',
//     this.hostName = '',
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title.isNotEmpty ? title : 'Live Class'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: SafeArea(
//         child: ZegoUIKitPrebuiltLiveStreaming(
//           appID: appID,
//           appSign: appSign,
//           userID: userID,
//           userName: userName,
//           liveID: liveID,
//           config: isHost
//               ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
//               : ZegoUIKitPrebuiltLiveStreamingConfig.audience()
//             ..useSpeakerWhenJoining = true,
//         ),
//       ),
//     );
//   }
// }


// class AudienceLivePage extends StatelessWidget {
//   final int appID;
//   final String appSign;
//   final String userID;
//   final String userName;
//   final String liveID;
//   final bool isHost;
//
//   const AudienceLivePage({
//     super.key,
//     required this.appID,
//     required this.appSign,
//     required this.userID,
//     required this.userName,
//     required this.liveID,
//     this.isHost = false, // default false, can be true for host
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: ZegoUIKitPrebuiltLiveStreaming(
//           appID: appID,
//           appSign: appSign,
//           userID: userID,
//           userName: userName,
//           liveID: liveID,
//           config: isHost
//               ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
//               : ZegoUIKitPrebuiltLiveStreamingConfig.audience()
//             ..useSpeakerWhenJoining = true,
//           // onLeaveRoom: () {
//           //   // Called when user leaves the live stream
//           //   Navigator.pop(context);
//           // },
//           // onLiveStreamingEnded: () {
//           //   // Called when host ends the live stream
//           //   ScaffoldMessenger.of(context).showSnackBar(
//           //     const SnackBar(content: Text('Live stream ended')),
//           //   );
//           //   Navigator.pop(context);
//           // },
//         ),
//       ),
//     );
//   }
// }
