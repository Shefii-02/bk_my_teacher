import 'dart:io' show File; // Only for mobile/desktop
import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:hive/hive.dart';
import '../core/constants/endpoints.dart';
import 'package:file_picker/file_picker.dart';

class TeacherApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // 🔹 Add auth token to header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, dynamic>> registerTeacher({
    required String teacherId,
    required String name,
    required String email,
    required String address,
    required String city,
    required String postalCode,
    required String district,
    required String state,
    required String country,
    required String interest,
    required String profession,
    required String readyToWork,
    required String offlineExp,
    required String onlineExp,
    required String homeExp,
    required List<String> selectedDays,
    required List<String> selectedHours,
    required List<String> teachingGrades,
    required List<String> teachingSubjects,
    required String experience,
    PlatformFile? cvFile,
    PlatformFile? avatar,
  }) async {
    try {
      final formData = FormData.fromMap({
        "teacher_id": teacherId,
        "name": name,
        "email": email,
        "address": address,
        "city": city,
        "postal_code": postalCode,
        "district": district,
        "state": state,
        "country": country,
        "interest": interest,
        "profession": profession,
        "ready_to_work": readyToWork,
        "experience": experience,
        "working_days": selectedDays.join(","),
        "working_hours": selectedHours.join(","),
        "teaching_grades": teachingGrades.join(","),
        "teaching_subjects": teachingSubjects.join(","),
        "offline_exp": offlineExp,
        "online_exp": onlineExp,
        "home_exp": homeExp,
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

      // ✅ CV handling
      if (cvFile != null) {
        if (kIsWeb) {
          formData.files.add(
            MapEntry(
              "cv_file",
              MultipartFile.fromBytes(cvFile.bytes!, filename: cvFile.name),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              "cv_file",
              await MultipartFile.fromFile(cvFile.path!, filename: cvFile.name),
            ),
          );
        }
      }
      final headers = {"X-Request-Source": kIsWeb ? "browser" : "app"};

      final response = await _dio.post(
        Endpoints.teacherSignup,
        data: formData,
        options: Options(headers: headers),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> fetchTeacherData() async {
    try {
      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';
      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(Endpoints.teacherHome);

      if (response.statusCode == 200 && response.data != null) {
        LaunchStatusService.saveUserData(response.data);
        return response.data;
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Error fetching teacher data");
    }
  }

  Future<Map<String, dynamic>> updateTeacherPersonal({
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

      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';
      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(Endpoints.teacherUpdatePersonal, data: formData);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Updating Failed");
    }
  }

  Future<Map<String, dynamic>> updateTeachingDetailsTeacher({
    required String interest,
    required String profession,
    required String readyToWork,
    required String offlineExp,
    required String onlineExp,
    required String homeExp,
    required List<String> selectedDays,
    required List<String> selectedHours,
    required List<String> teachingGrades,
    required List<String> teachingSubjects,
  }) async {
    try {
      final formData = FormData.fromMap({
        "interest": interest,
        "profession": profession,
        "ready_to_work": readyToWork,
        "working_days": selectedDays.join(","),
        "working_hours": selectedHours.join(","),
        "teaching_grades": teachingGrades.join(","),
        "teaching_subjects": teachingSubjects.join(","),
        "offline_exp": offlineExp,
        "online_exp": onlineExp,
        "home_exp": homeExp,
      });

      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';
      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(Endpoints.teacherUpdateTeachingDetails, data: formData);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> updateCvTeacher({PlatformFile? cvFile}) async {
    try {
      print(cvFile);
      print("*******");
      final formData = FormData();
      // ✅ CV handling
      if (cvFile != null) {
        if (kIsWeb) {
          formData.files.add(
            MapEntry(
              "cv_file",
              MultipartFile.fromBytes(cvFile.bytes!, filename: cvFile.name),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              "cv_file",
              await MultipartFile.fromFile(cvFile.path!, filename: cvFile.name),
            ),
          );
        }
      }
      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';
      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(Endpoints.teacherUpdateCv, data: formData);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }
}
