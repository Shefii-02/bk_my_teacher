import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class ConferencePage extends StatelessWidget {
  final int appID;
  final String appSign;
  final String userID;
  final String userName;
  final String conferenceID;
  final bool isHost;

  const ConferencePage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.conferenceID,
    this.isHost = false, // default false, can be true for host
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text(''),
        // ZegoUIKitPrebuiltVideoConference(
        //   appID: appID,
        //   appSign: appSign,
        //   userID: userID,
        //   userName: userName,
        //   conferenceID: conferenceID,
        //   config: ZegoUIKitPrebuiltVideoConferenceConfig(),
        // ),
      ),
    );
  }
}



// class ConferencePage extends StatelessWidget {
//   final Map<String, String> params;
//   const ConferencePage({super.key, required this.params});
//
//   @override
//   Widget build(BuildContext context) {
//     final int appID = int.parse(params['appID']!);
//     final String appSign = params['appSign']!;
//     final String userID = params['userID']!;
//     final String userName = params['userName']!;
//     final String conferenceID = params['conferenceID']!;
//
//     return SafeArea(
//       child: ZegoUIKitPrebuiltVideoConference(
//         appID: appID,
//         appSign: appSign,
//         userID: userID,
//         userName: userName,
//         conferenceID: conferenceID,
//         config: ZegoUIKitPrebuiltVideoConferenceConfig(),
//       ),
//     );
//   }
// }
