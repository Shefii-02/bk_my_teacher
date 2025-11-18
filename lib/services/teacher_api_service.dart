import 'dart:io' show File; // Only for mobile/desktop
import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:hive/hive.dart';
import '../core/constants/endpoints.dart';
import 'package:file_picker/file_picker.dart';

import '../model/achievement_level.dart';
import '../model/course_details_model.dart';
import '../model/course_model.dart';
import '../model/course_review_model.dart';
import '../model/level_data.dart';
import '../model/schedule_model.dart';
import '../model/student_review.dart';
import '../model/time_card_model.dart';
import '../model/statistics_model.dart';
import '../model/stats_api_response.dart' hide StatisticsModel;

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

  // ---------------------------------------------------------------------------
  // 🔹 COMMON — Load token & add in header
  // ---------------------------------------------------------------------------
  Future<void> _loadAuth() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
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
      // final box = await Hive.openBox('app_storage');
      // final token = box.get('auth_token') ?? '';
      // if (token.isNotEmpty) setAuthToken(token);
      await _loadAuth();
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

      // final box = await Hive.openBox('app_storage');
      // final token = box.get('auth_token') ?? '';
      // if (token.isNotEmpty) setAuthToken(token);
      await _loadAuth();
      final response = await _dio.post(
        Endpoints.teacherUpdatePersonal,
        data: formData,
      );

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

      // final box = await Hive.openBox('app_storage');
      // final token = box.get('auth_token') ?? '';
      // if (token.isNotEmpty) setAuthToken(token);
      await _loadAuth();

      final response = await _dio.post(
        Endpoints.teacherUpdateTeachingDetails,
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<Map<String, dynamic>> updateCvTeacher({PlatformFile? cvFile}) async {
    try {
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

      await _loadAuth();

      final response = await _dio.post(
        Endpoints.teacherUpdateCv,
        data: formData,
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Signup failed");
    }
  }

  Future<ScheduleResponse> fetchTeacherSchedule() async {
    // final box = await Hive.openBox('app_storage');
    // final token = box.get('auth_token') ?? '';
    // if (token.isNotEmpty) setAuthToken(token);
    await _loadAuth();

    final response = await _dio.post('/teacher/schedule');

    // assume backend returns JSON structure as agreed
    return ScheduleResponse.fromJson(response.data);
  }

  Future<CourseSummary> fetchTeacherCourses() async {
    await _loadAuth();
    final res = await _dio.post('/teacher/courses');
    return CourseSummary.fromJson(res.data);
  }

  Future<CourseDetails> fetchTeacherCourseSummary(int id) async {
    await _loadAuth();
    final res = await _dio.post('/teacher/course-details', data: {"id": id});
    return CourseDetails.fromJson(res.data);
  }

  Future<StatisticsModel> fetchStatistics() async {
    try {
      await _loadAuth();
      final response = await _dio.post("/teacher/statistics");

      if (response.statusCode == 200 && response.data != null) {
        return StatisticsModel.fromJson(response.data);
      } else {
        throw Exception(
          "Invalid API response: ${response.statusCode} → ${response.data}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Dio Error: ${e.message}");
    } catch (e) {
      throw Exception("Unknown Error: $e");
    }
  }

  Future<CourseReviewResponse> fetchReviews() async {
    await _loadAuth();
    final res = await _dio.post("/teacher/reviews");

    return CourseReviewResponse.fromJson(res.data);
  }

  Future<AchievementResponse> fetchAchievements() async {
    await _loadAuth();
    final res = await _dio.get("/teacher/achievements");

    return AchievementResponse.fromJson(res.data);
  }

  Future<List<TimeCardModel>> fetchSpendTime() async {
    await _loadAuth();
    final res = await _dio.post("/teacher/spend-time");
    final List data = res.data["data"];

    return data.map((e) => TimeCardModel.fromJson(e)).toList();
  }

  Future<List<TimeCardModel>> fetchWatchTime() async {
    await _loadAuth();
    final res = await _dio.post("/teacher/watch-time");
    final List data = res.data["data"];
    return data.map((e) => TimeCardModel.fromJson(e)).toList();
  }


  Future<LevelData> fetchCurrentLevel() async {
    await _loadAuth();
    final response = await _dio.post("/teacher/achievement-level");
    return LevelData.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> fetchOwnCourses() async {
    await _loadAuth();
    final res = await _dio.post('/teacher/own-courses');
    return Map<String, dynamic>.from(res.data);
  }


  Future<StatisticsModel> fetchSpendStatistics() async {
    try {
      await _loadAuth();
      final response = await _dio.post("/teacher/spend-statistics");

      if (response.statusCode == 200 && response.data != null) {
        return StatisticsModel.fromJson(response.data);
      } else {
        throw Exception(
          "Invalid API response: ${response.statusCode} → ${response.data}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Dio Error: ${e.message}");
    } catch (e) {
      throw Exception("Unknown Error: $e");
    }
  }

  Future<StatisticsModel> fetchWatchStatistics() async {
    try {
      await _loadAuth();
      final response = await _dio.post("/teacher/watch-statistics");

      if (response.statusCode == 200 && response.data != null) {
        return StatisticsModel.fromJson(response.data);
      } else {
        throw Exception(
          "Invalid API response: ${response.statusCode} → ${response.data}",
        );
      }
    } on DioException catch (e) {
      throw Exception("Dio Error: ${e.message}");
    } catch (e) {
      throw Exception("Unknown Error: $e");
    }
  }


  Future<List<StudentReviewMain>> fetchMainReviews() async {
    try {
      await _loadAuth();
      final response = await _dio.post("/teacher/student-reviews");

      if (response.statusCode == 200) {
        List list = response.data["reviews"] ?? [];
        return list.map((e) => StudentReviewMain.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("REVIEW FETCH ERROR: $e");
      return [];
    }
  }

}
