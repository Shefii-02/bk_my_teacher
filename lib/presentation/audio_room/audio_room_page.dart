import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';


class AudioRoomPage extends StatelessWidget {
  final int appID;
  final String appSign;
  final String userID;
  final String userName;
  final String roomID;
  final bool isHost;

  const AudioRoomPage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.roomID,
    this.isHost = false, // default false, can be true for host
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text(''),
        // child: ZegoUIKitPrebuiltLiveAudioRoom(
        // appID: appID,
        // appSign: appSign,
        // userID: userID,
        // userName: userName,
        // roomID: roomID,
        // config: ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
      // )
      ),
    );
  }
}


// class AudioRoomPage extends StatelessWidget {
//   final Map<String, String> params;
//   const AudioRoomPage({super.key, required this.params});
//
//   @override
//   Widget build(BuildContext context) {
//     final int appID = int.parse(params['appID']!);
//     final String appSign = params['appSign']!;
//     final String userID = params['userID']!;
//     final String userName = params['userName']!;
//     final String roomID = params['roomID']!;
//
//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveAudioRoom(
//         appID: appID,
//         appSign: appSign,
//         userID: userID,
//         userName: userName,
//         roomID: roomID,
//         config: ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
//       )
//     );
//   }
// }
