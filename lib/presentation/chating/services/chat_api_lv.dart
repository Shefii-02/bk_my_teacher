import 'dart:io';
import 'package:BookMyTeacher/core/constants/chat_constants.dart';
import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatApiLv {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '${Endpoints.base}',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 500),
    ),
  );


  // 🔹 Add auth token to header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }


  Future<void> _loadAuth() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
  }


  // ── Auth header helper ───────────────────────────────────
  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ✅ Clear Chat
  Future<void> clearChat(int conversationId) async {
    await _loadAuth();
    await _dio.post('/chat/clear/$conversationId');
  }

  // ✅ Report Chat
  Future<void> reportChat({required int conversationId, String? reason}) async {
    await _loadAuth();
    await _dio.post(
      '/chat/report',
      data: {
        "conversation_id": conversationId,
        "reason": reason ?? "Reported from app",
      },
    );
  }

  // ✅ Exit Group
  Future<void> exitGroup(int conversationId) async {
    await _loadAuth();
    await _dio.post(
      '/chat/exit-group',
      data: {"conversation_id": conversationId},
    );
  }
}
