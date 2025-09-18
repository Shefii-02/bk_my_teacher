import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/endpoints.dart';

class StudentApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

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
    File? avatar,
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

        if (avatar != null)
          "avatar": await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
      });

      print("➡️ Posting Teacher Signup");
      print("Data: ${formData.fields}");

      final response = await _dio.post(Endpoints.studentSignup, data: formData);
      print("✅ Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> fetchStudentData(String studentId) async {
    try {
      final formData = FormData.fromMap({
        "student_id": studentId,
      });

      final response = await _dio.post(
        Endpoints.studentHome,
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
      throw Exception(e.response?.data ?? "Error fetching student data");
    }
  }


}
