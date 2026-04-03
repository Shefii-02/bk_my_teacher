// // services/api_service.dart
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../core/constants/chat_constants.dart';
// import '../presentation/chating/models/conversation_model.dart';
//
// class ChatApiService {
//   static final ChatApiService _instance = ChatApiService._internal();
//   factory ChatApiService() => _instance;
//
//   late final Dio _dio;
//   String? _token;
//   String baseUrl = AppConstants.baseUrl;
//   ChatApiService._internal() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: "$baseUrl/api",
//         connectTimeout: const Duration(seconds: 15),
//       ),
//     );
//
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           _token ??= (await SharedPreferences.getInstance()).getString('token');
//           if (_token != null) {
//             options.headers['Authorization'] = 'Bearer $_token';
//           }
//           handler.next(options);
//         },
//       ),
//     );
//   }
//
//   // 🔹 Conversations
//   Future<List<ConversationModel>> getConversations(String token) async {
//
//     final res = await _dio.get(
//       '/chat/conversations',
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//     final list = res.data as List;
//     return list.map((e) => ConversationModel.fromJson(e)).toList();
//   }
//
//   // 🔹 Messages
//   Future<List<MessageModel>> getMessages(
//       int convId,
//       String token, {
//         required int offset,
//       }) async {
//     try {
//       final res = await _dio.get(
//         '/chat/messages/$convId',
//         options: Options(headers: {
//           "Authorization": "Bearer $token",
//         }),
//         queryParameters: {
//           "offset": offset, // ✅ pagination
//         },
//       );
//
//       print("API RESPONSE: ${res.data}");
//
//       // ✅ Handle both API formats
//       List list;
//       if (res.data is List) {
//         list = res.data;
//       } else if (res.data is Map && res.data['messages'] != null) {
//         list = res.data['messages'];
//       } else {
//         list = [];
//       }
//
//       // ✅ Parse + filter invalid messages
//       final parsed = list
//           .map((e) => MessageModel.fromJson(e))
//           .where((m) =>
//       m.senderId != 0
//           // &&                      // ❌ remove null sender
//           // m.messageType != MessageType.unknown    // ❌ remove invalid type
//       )
//           .toList();
//
//       // ✅ Debug logs
//       print("FINAL PARSED COUNT: ${parsed.length}");
//       for (var m in parsed) {
//         print("${m.id} | ${m.senderId} | ${m.content} | ${m.messageType}");
//       }
//
//       return parsed;
//
//     } catch (e) {
//       print("GET MESSAGES ERROR: $e");
//       return [];
//     }
//   }
//   // 🔹 Upload File / Voice
//   Future<String> uploadFile(File file) async {
//     final formData = FormData.fromMap({
//       'file': await MultipartFile.fromFile(file.path),
//     });
//
//     final res = await _dio.post('/upload', data: formData);
//     return res.data['file_url'];
//   }
// }
