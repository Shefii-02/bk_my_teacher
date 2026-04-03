// lib/services/chat_api_service.dart

import 'dart:io';
import 'package:BookMyTeacher/core/constants/chat_constants.dart';
import 'package:dio/dio.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';


class ChatApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // ── Auth header helper ───────────────────────────────────
  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ── Conversations list ───────────────────────────────────
  Future<List<ConversationModel>> getConversations(String token) async {
    final res = await _dio.get('/chat/conversations', options: _auth(token));
    final list = res.data as List;
    return list.map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // ── Messages (paginated) ─────────────────────────────────
  // Server returns newest first (ORDER BY id DESC), so index 0 = latest.
  // ListView(reverse:true) displays them correctly without any extra reversal.
  Future<List<MessageModel>> getMessages(
      int conversationId,
      String token, {
        int offset = 0,
        int limit  = 30,
      }) async {
    final res = await _dio.get(
      '/chat/messages/$conversationId',
      queryParameters: {'offset': offset, 'limit': limit},
      options: _auth(token),
    );
    final list = res.data as List;
    return list
        .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── Create / get direct conversation ────────────────────
  Future<int> createDirectChat(int targetUserId, String token) async {
    final res = await _dio.post(
      '/chat/create',
      data: {'targetUserId': targetUserId},
      options: _auth(token),
    );
    return res.data['conversationId'] as int;
  }

  // ── Upload file (voice / pdf / docx) ────────────────────
  Future<Map<String, dynamic>> uploadFile(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final res = await _dio.post('/upload', data: formData);

    return {
      'url':          res.data['url']          as String,
      'originalName': res.data['originalName'] as String? ?? file.path.split('/').last,
      'size':         res.data['size']         as int?    ?? 0,
    };
  }
}