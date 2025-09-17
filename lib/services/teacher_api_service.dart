import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/endpoints.dart';

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
    File? cvFile,
    File? avatar,
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

        if (avatar != null)
          "avatar": await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split('/').last,
          ),

        if (cvFile != null)
          "cv_file": await MultipartFile.fromFile(
            cvFile.path,
            filename: cvFile.path.split('/').last,
          ),
      });

      print("➡️ Posting Teacher Signup");
      print("Data: ${formData.fields}");

      final response = await _dio.post(Endpoints.teacherSignup, data: formData);
      print("✅ Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  // Future<Map<String, dynamic>> fetchTeacherData(String teacherId) async {
  //   try {
  //     final formData = FormData.fromMap({
  //       "teacher_id": teacherId,
  //     });
  //
  //     final response = await _dio.post(
  //       Endpoints.teacherHome,
  //       data: formData, // send as JSON body
  //     );
  //
  //     if (response.statusCode == 200 && response.data != null) {
  //       // Dio automatically parses JSON response to Map<String, dynamic>
  //       print("****************");
  //       print(response);
  //       print("****************");
  //       return response.data;
  //     } else {
  //       throw Exception("Failed to load teacher data");
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(e.response?.data ?? "Error fetching teacher data");
  //   }
  // }

  Future<Map<String, dynamic>> fetchTeacherData(String teacherId) async {
    try {
      final formData = FormData.fromMap({
        "teacher_id": teacherId,
      });

      final response = await _dio.post(
        Endpoints.teacherHome,
        data: formData, // send as a form data body
      );

      if (response.statusCode == 200 && response.data != null) {
        // Dio automatically parses JSON response to Map<String, dynamic>
        return response.data;
      } else {
        throw Exception("Failed to load teacher data: Server responded with status ${response.statusCode}");
      }
    } on DioException catch (e) {
      // Catch Dio-specific errors (e.g., network issues, bad status codes)
      throw Exception(e.response?.data ?? "Error fetching teacher data");
    }
  }

}
