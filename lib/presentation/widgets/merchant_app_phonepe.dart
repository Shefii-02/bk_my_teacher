// import 'dart:convert';
// import 'dart:io';
//
// import 'package:BookMyTeacher/presentation/widgets/upi_app.dart';
// import 'package:flutter/material.dart';
// // import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
//
// class MerchantApp extends StatefulWidget {
//   const MerchantApp({super.key});
//
//   @override
//   State<MerchantApp> createState() => MerchantScreen();
// }
//
// class MerchantScreen extends State<MerchantApp> {
//   String environment = "SANDBOX";
//   String merchantId = "MERCHNATID";
//   String flowId = "test";
//   bool enableLogs = true;
//
//   String appSchema = "test";
//
//   final Map<String, dynamic> payload = {
//     "orderId":"OMO2510100948506815286431",
//     "merchantId":"MERCHNATID",
//     "token":"token.eyJleHBpcmVzT24iOjE3NjAwOTMzMzA2ODEsIm1lcmNoYW50SWQiOiJURVNUVjJVQVQiLCJtZXJjaGFudE9yZGVySWQiOiJUWDEyMzQ1NiJ9.J2KmXL6WhCLK2dngLOfSaWhlNTVa7h2uJ9trWRhk958",
//     "paymentMode":{"type":"PAY_PAGE"}
//   };
//
//
//   late final String request = jsonEncode(payload);
//
//
//
//   void initSdk(){
//
//     PhonePePaymentSdk.init(environment, merchantId, flowId,
//         enableLogs).then((isInitialized)=> {
//       print("initialized : $isInitialized")
//     }).catchError((onError){
//       print("onError : $onError");
//       return <dynamic>{};
//
//     });
//
//
//   }
//
//   void startTransaction(){
//
//     PhonePePaymentSdk.startTransaction(request, appSchema)
//         .then((response) {
//       if(response != null){
//         String status = response['status'].toString();
//         String error = response['error'].toString();
//         if(status == 'SUCCESS'){
//           print("success");
//
//         }else{
//           print("failed");
//
//         }
//
//
//       }else{
//         print("Flow incomplete");
//       }
//     });
//
//
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text("Phone Pe Payment"),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//
//             ElevatedButton(onPressed: initSdk,
//                 child: Text("Init SDK")),
//
//             ElevatedButton(onPressed: startTransaction,
//                 child: Text("Start Transaction"))
//
//
//           ],
//         ),
//       ),
//
//     );
//   }
// }