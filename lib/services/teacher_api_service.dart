import 'dart:io';
import 'package:dio/dio.dart';

class TeacherApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://bookmyteacher.shefii.com/api",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));


  Future<Map<String, dynamic>> registerTeacher({
    required String name,
    required String email,
    required String address,
    required String city,
    required String postalCode,
    required String district,
    required String state,
    required String country,
    required String profession,
    required String readyToWork,
    required List<String> selectedDays,
    required List<String> selectedHours,
    required List<String> teachingGrades,
    required List<String> teachingSubjects,
    required String experience,
    File? cvFile,
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
        "profession": profession,
        "ready_to_work": readyToWork,
        "experience": experience,
        "working_days": selectedDays.join(","),
        "working_hours": selectedHours.join(","),
        "teaching_grades": teachingGrades.join(","),
        "teaching_subjects": teachingSubjects.join(","),
        if (cvFile != null)
          "cv_file": await MultipartFile.fromFile(
            cvFile.path,
            filename: cvFile.path.split('/').last,
          ),
      });

      print("➡️ Posting Teacher Signup");
      print("Data: ${formData.fields}");
      final response = await _dio.post("/teacher-signup", data: formData);
      print("✅ Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }
}
