import 'dart:io' show File; // Only for mobile/desktop
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../core/constants/endpoints.dart';
import 'package:file_picker/file_picker.dart';

class TeacherApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

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
              MultipartFile.fromBytes(
                avatar.bytes!,
                filename: avatar.name,
              ),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              "avatar",
              await MultipartFile.fromFile(
                avatar.path!,
                filename: avatar.name,
              ),
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
              MultipartFile.fromBytes(
                cvFile.bytes!,
                filename: cvFile.name,
              ),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              "cv_file",
              await MultipartFile.fromFile(
                cvFile.path!,
                filename: cvFile.name,
              ),
            ),
          );
        }
      }
      final headers = {
        "X-Request-Source": kIsWeb ? "browser" : "app",
      };



      final response = await _dio.post(Endpoints.teacherSignup, data: formData,options: Options(headers: headers));

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> fetchTeacherData(String teacherId) async {
    try {
      final formData = FormData.fromMap({"teacher_id": teacherId});

      final response = await _dio.post(Endpoints.teacherHome, data: formData);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Error fetching teacher data");
    }
  }



}
