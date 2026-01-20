import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../core/constants/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class StudentApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // 🔹 Add auth token to header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ---------------------------------------------------------------------------
  // 🔹 COMMON — Load token & add in header
  // ---------------------------------------------------------------------------
  Future<void> _loadAuth() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
  }

  Future<Map<String, dynamic>> registerStudent({
    required String studentId,
    required String studentName,
    required String parentName,
    required String email,
    required String address,
    required String city,
    required String postalCode,
    required String district,
    required String state,
    required String country,
    required String interest,
    required List<String> selectedDays,
    required List<String> selectedHours,
    required List<String> seekingGrades,
    required List<String> seekingSubjects,
    PlatformFile? avatar,
  }) async {
    try {
      final formData = FormData.fromMap({
        "student_id": studentId,
        "student_name": studentName,
        "parent_name": parentName,
        "email": email,
        "address": address,
        "city": city,
        "postal_code": postalCode,
        "district": district,
        "state": state,
        "country": country,

        "interest": interest,
        "working_days": selectedDays.join(","),
        "working_hours": selectedHours.join(","),
        "teaching_grades": seekingGrades.join(","),
        "teaching_subjects": seekingSubjects.join(","),

        // if (avatar != null)
        //   "avatar": await MultipartFile.fromFile(
        //     avatar.path,
        //     filename: avatar.path.split('/').last,
        //   ),
      });

      // Attach avatar
      // ✅ Attach avatar
      if (avatar != null) {
        if (kIsWeb) {
          formData.files.add(
            MapEntry(
              "avatar",
              MultipartFile.fromBytes(avatar.bytes!, filename: avatar.name),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              "avatar",
              await MultipartFile.fromFile(avatar.path!, filename: avatar.name),
            ),
          );
        }
      }

      // Add request source info
      final headers = {"X-Request-Source": kIsWeb ? "browser" : "app"};
      // print("➡️ Posting Teacher Signup");
      // print("Data: ${formData.fields}");
      await _loadAuth();
      final response = await _dio.post(
        Endpoints.studentSignup,
        data: formData,
        options: Options(headers: headers),
      );
      // print("✅ Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> fetchStudentData() async {
    try {
      // final formData = FormData.fromMap({
      //   "student_id": studentId,
      // });

      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';

      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(Endpoints.studentHome);

      if (response.statusCode == 200 && response.data != null) {
        // Dio automatically parses JSON response to Map<String, dynamic>
        return response.data;
      } else {
        throw Exception(
          "Failed to load teacher data: Server responded with status ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      // Catch Dio-specific errors (e.g., network issues, bad status codes)
      throw Exception(e.response?.data ?? "Error fetching student data");
    }
  }




  Future<Map<String, dynamic>> updateStudentPersonal({
    required String name,
    required String email,
    required String address,
    required String city,
    required String postalCode,
    required String district,
    required String state,
    required String country,
    PlatformFile? avatar,
  }) async {
    try {
      final formData = FormData.fromMap({
        "name": name,
        "email": email,
        "address": address,
        "city": city,
        "postal_code": postalCode,
        "district": district,
        "state": state,
        "country": country,
      });

      // ✅ Avatar handling
      if (avatar != null) {
        if (kIsWeb) {
          formData.files.add(
            MapEntry(
              "avatar",
              MultipartFile.fromBytes(avatar.bytes!, filename: avatar.name),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              "avatar",
              await MultipartFile.fromFile(avatar.path!, filename: avatar.name),
            ),
          );
        }
      }

      // final box = await Hive.openBox('app_storage');
      // final token = box.get('auth_token') ?? '';
      // if (token.isNotEmpty) setAuthToken(token);
      await _loadAuth();
      final response = await _dio.post(
        Endpoints.studentUpdatePersonal,
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Updating Failed");
    }
  }

}
