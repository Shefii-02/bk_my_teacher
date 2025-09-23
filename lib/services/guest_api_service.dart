import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../core/constants/endpoints.dart';
import 'package:file_picker/file_picker.dart';

class GuestApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 🔹 Add auth token to header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, dynamic>> registerGuest({
    required String fullName,
    required String email,
    PlatformFile? avatar,
  }) async {
    print("➡️ Sending fullName: $fullName, email: $email");

    try {
      final formDataMap = {
        "student_name": fullName, // ✅ Laravel expects student_name
        "email": email,
      };

      final formData = FormData.fromMap(formDataMap);

      if (avatar != null) {
        if (kIsWeb && avatar.bytes != null) {
          formData.files.add(
            MapEntry(
              "avatar",
              MultipartFile.fromBytes(
                avatar.bytes!,
                filename: avatar.name ?? "avatar.png",
              ),
            ),
          );
        } else if (avatar.path != null) {
          formData.files.add(
            MapEntry(
              "avatar",
              await MultipartFile.fromFile(
                avatar.path!,
                filename: avatar.name ?? "avatar.png",
              ),
            ),
          );
        }
      }

      final headers = {"X-Request-Source": kIsWeb ? "browser" : "app"};

      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';

      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(
        Endpoints.guestSignup,
        data: formData,
        options: Options(headers: headers),
      );

      print("➡️ Server Response: ${response.data}");

      return response.data;
    } on DioException catch (e) {
      print("➡️ DioException: ${e.response?.data}");
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> fetchGuestData(String guestId) async {
    try {
      final formData = FormData.fromMap({"guest_id": guestId});

      final response = await _dio.post(Endpoints.studentHome, data: formData);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception(
          "Failed to load guest data: Server responded with status ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Error fetching guest data");
    }
  }
}
