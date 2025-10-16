import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class OneOnOneCallPage extends StatelessWidget {
  final int appID;
  final String appSign;
  final String userID;
  final String userName;
  final bool isHost;
  final String callID;

  const OneOnOneCallPage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.callID,
    this.isHost = false, // default false, can be true for host
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text('')
        // ZegoUIKitPrebuiltCall(
        //   appID: appID,
        //   appSign: appSign,
        //   userID: userID,
        //   userName: userName,
        //   callID: callID,
        //   config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
        // ),
      ),
    );
  }
}

//
// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
//
// class OneOnOneCallPage extends StatelessWidget {
//   final Map<String, String> params;
//   const OneOnOneCallPage({super.key, required this.params});
//
//   @override
//   Widget build(BuildContext context) {
//     final int appID = int.parse(params['appID']!);
//     final String appSign = params['appSign']!;
//     final String userID = params['userID']!;
//     final String userName = params['userName']!;
//     final String callID = params['callID']!;
//
//     return SafeArea(
//       child: ZegoUIKitPrebuiltCall(
//         appID: appID,
//         appSign: appSign,
//         userID: userID,
//         userName: userName,
//         callID: callID,
//         config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
//       ),
//     );
//   }
// }
