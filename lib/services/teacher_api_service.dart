import 'dart:convert';
import 'dart:io' show File; // Only for mobile/desktop
import 'package:BookMyTeacher/model/webinar_details_model.dart';
import 'package:BookMyTeacher/model/workshop_details_model.dart';
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
    // required List<String> selectedDays,
    // required List<String> selectedHours,
    // required List<String> teachingGrades,
    // required List<String> teachingSubjects,
    required Map<String, dynamic> availability,
    required Map<String, dynamic> teachingData,
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
        // "working_days": selectedDays.join(","),
        // "working_hours": selectedHours.join(","),
        // "teaching_grades": teachingGrades.join(","),
        // "teaching_subjects": teachingSubjects.join(","),
        "availability": jsonEncode(availability),
        "teaching_data": jsonEncode(teachingData),
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
      await _loadAuth();

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

  Future<WebinarDetailsModel> fetchTeacherWebinarSummary(int id) async {
    await _loadAuth();
    final res = await _dio.post('/teacher/webinar-details', data: {"id": id});

    return WebinarDetailsModel.fromJson(res.data);
  }

  Future<WorkshopDetailsModel> fetchTeacherWorkshopSummary(int id) async {
    await _loadAuth();
    final res = await _dio.post('/teacher/workshop-details', data: {"id": id});
    return WorkshopDetailsModel.fromJson(res.data);
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
      final response = await _dio.post("/student-reviews");

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

  Future<Map<String, dynamic>> createCourseClass(
    Map<String, dynamic> payload,
  ) async {
    await _loadAuth();

    final response = await _dio.post(
      "/teacher/course-class/create",
      data: payload, // no need jsonEncode
    );

    return response.data;
  }

  // ─── In your TeacherApiService class ─────────────────────────────────────────

  Future<Map<String, dynamic>> uploadMaterial({
    required int courseId,
    required String title,
    required String type,
    required File file,
    int position = 0,
  }) async {
    await _loadAuth();
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'course_id': courseId.toString(),
        'title': title,
        'position': position.toString(),
        'status': 'published',
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: _getDioMediaType(type), // ✅ safe
        ),
      });

      final response = await _dio.post(
        '/teacher/course/material/upload',
        data: formData,
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': data['message'] ?? 'Uploaded successfully',
        };
      } else {
        return {'status': false, 'message': data['message'] ?? 'Upload failed'};
      }
    } on DioException catch (e) {
      debugPrint('uploadMaterial DioError: ${e.response?.data}');
      final data = e.response?.data;
      final message = (data is Map)
          ? data['message'] ?? 'Upload failed'
          : 'Upload failed';
      return {'status': false, 'message': message};
    } catch (e) {
      debugPrint('uploadMaterial error: $e');
      return {'status': false, 'message': 'Something went wrong'};
    }
  }

  // ✅ Safe media type — no string splitting
  //   DioMediaType _getDioMediaType(String type) {
  //     switch (type) {
  //       case 'pdf'   : return DioMediaType('application', 'pdf');
  //       case 'image' : return DioMediaType('image', 'jpeg');
  //       case 'voice' : return DioMediaType('audio', 'm4a');
  //       default      : return DioMediaType('application', 'octet-stream');
  //     }
  //   }

  // ─── MIME helper ──────────────────────────────────────────────────────────────

  // ✅ Safe mime split
  DioMediaType _getDioMediaType(String type) {
    switch (type) {
      case 'pdf':
        return DioMediaType('application', 'pdf');
      case 'image':
        return DioMediaType('image', 'jpeg');
      case 'voice':
        return DioMediaType('audio', 'm4a');
      default:
        return DioMediaType('application', 'octet-stream');
    }
  }

  Future<Map<String, dynamic>> updateCourseClass(
    Map<String, dynamic> payload,
  ) async {
    await _loadAuth();
    try {
      final response = await _dio.post(
        '/teacher/course/class/update',
        data: payload,
      );
      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': data['message'] ?? 'Updated successfully',
        };
      } else {
        return {'status': false, 'message': data['message'] ?? 'Update failed'};
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Update failed';
      return {'status': false, 'message': message};
    } catch (e) {
      return {'status': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> deleteCourseClass(String classId) async {
    await _loadAuth();
    try {
      final response = await _dio.post(
        '/teacher/course/class/delete',
        data: {'id': classId},
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': data['message'] ?? 'Class deleted successfully',
        };
      } else {
        return {'status': false, 'message': data['message'] ?? 'Delete failed'};
      }
    } on DioException catch (e) {
      debugPrint('deleteCourseClass DioError: ${e.response?.data}');
      final message = e.response?.data?['message'] ?? 'Delete failed';
      return {'status': false, 'message': message};
    } catch (e) {
      debugPrint('deleteCourseClass error: $e');
      return {'status': false, 'message': 'Something went wrong'};
    }
  }
  Future<Map<String, dynamic>> deleteCourseMaterial(String materialId) async {
    await _loadAuth();
    try {
      final response = await _dio.post(
        '/teacher/course/material/delete',
        data: {'id': materialId},
      );

      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': data['message'] ?? 'Material deleted successfully',
        };
      } else {
        return {'status': false, 'message': data['message'] ?? 'Delete failed'};
      }
    } on DioException catch (e) {
      debugPrint('deleteCourseMaterial DioError: ${e.response?.data}');
      final message = e.response?.data?['message'] ?? 'Delete failed';
      return {'status': false, 'message': message};
    } catch (e) {
      debugPrint('deleteCourseMaterial error: $e');
      return {'status': false, 'message': 'Something went wrong'};
    }

  }


}
