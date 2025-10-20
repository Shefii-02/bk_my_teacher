import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class AudiencePage extends StatelessWidget {
  final int appID;
  final String appSign;
  final String userID;
  final String userName;
  final String liveID;
  final bool isHost;

  const AudiencePage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    this.isHost = false, // default false, can be true for host
  });

  @override
  Widget build(BuildContext context) {
    return
    //   Scaffold(
    //   body: SafeArea(
    //     child: ZegoUIKitPrebuiltLiveStreaming(
    //       appID: appID,
    //       appSign: appSign,
    //       userID: userID,
    //       userName: userName,
    //       liveID: liveID,
    //       config: isHost
    //           ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
    //           : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
    //     ),
    //   ),
    // );
     Text('');
  }
}

// class AudiencePage extends StatelessWidget {
//   final Map<String, String> params;
//   const AudiencePage({super.key, required this.params});
//
//   @override
//   Widget build(BuildContext context) {
//     final int appID = int.parse(params['appID']!);
//     final String appSign = params['appSign']!;
//     final String userID = params['userID']!;
//     final String userName = params['userName']!;
//     final String liveID = params['liveID']!;
//     final bool isHost = params['isHost'] == 'true';
//
//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveStreaming(
//         appID: appID,
//         appSign: appSign,
//         userID: userID,
//         userName: userName,
//         liveID: liveID,
//         config: isHost
//             ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
//             : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
//       ),
//     );
//   }
// }
