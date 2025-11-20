import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../core/constants/endpoints.dart';
import '../model/grade_board_subject_model.dart';
import '../model/notification_item.dart';
import '../model/performance_summary.dart';
import '../model/student_model.dart';
import '../model/student_performance.dart';
import '../model/top_banner.dart';
import '../providers/student_performance_provider.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class ApiService {
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

    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }


  Future<StudentPerformance> getStudentPerformance() async {
    try {
      await _loadAuth();
      final res = await _dio.post("/student/performance");

      final data = res.data;

      if (data == null || data["data"] == null || data["data"] is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      return StudentPerformance.fromJson(data["data"]);
    } catch (e) {
      throw Exception("Failed to load performance: $e");
    }
  }



  /// ✅ Server health check
  Future<bool> checkServer() async {
    try {
      final response = await _dio.get(Endpoints.checkServer);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == "development") {
          // 🚨 Maintenance mode
          return false;
        } else {
          return true;
        }
      } else {
        return false;
      }

      // if (response.statusCode == 200) {
      //   // If API returns JSON with success
      //   if (response.data is Map && response.data['status'] == 'ok') {
      //     return true;
      //   }
      //   return true; // if just 200 OK without body
      // }
      // return false;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phoneNumber) async {
    try {
      final type = kIsWeb ? "browser" : "app";
      final response = await _dio.post(
        Endpoints.sendOtpSignIn,
        data: json.encode({'mobile': phoneNumber, 'type': type}),
      );

      final responseData = response.data;

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'OTP sent successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to send OTP',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.verifyOtpSignIn,
        data: json.encode({'mobile': phoneNumber, 'otp': otp}),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'OTP verified successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid OTP',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOtp(
    String phoneNumber,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.reSendOtp,
        data: json.encode({'mobile': phoneNumber, 'type': 'resend'}),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'OTP resent successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to resend OTP',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signupSendOtp(
    String phoneNumber,
  ) async {
    try {
      final type = kIsWeb ? "browser" : "app";
      final response = await _dio.post(
        Endpoints.sendOtpSignUp,
        data: json.encode({'mobile': phoneNumber, 'type': type}),
      );

      final responseData = response.data;

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'OTP sent successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to send OTP',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> signupVerifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.verifyOtpSignUp,
        data: json.encode({'mobile': phoneNumber, 'otp': otp}),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'OTP verified successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid OTP',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> referralStats() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final response = await _dio.post("/referral/stats");
    return response.data;
  }

  Future<Map<String, dynamic>> getTeachers() async {
    final res = await _dio.get('/teachers');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getTeacherById(int id) async {
    final res = await _dio.get('/teacher/$id');

    return Map<String, dynamic>.from(res.data);
  }

  /// --- Error handler ---
  ApiResponse<Map<String, dynamic>> _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiResponse(success: false, message: "Request timeout");
    } else if (e.response != null) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? "Server error",
        data: e.response?.data,
      );
    } else {
      return ApiResponse(
        success: false,
        message: "Network error: ${e.message}",
      );
    }
  }

  /// Fetch teaching grades
  Future<List<Map<String, dynamic>>> getListingGrades() async {
    try {
      final response = await _dio.get(Endpoints.fetchGrads);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data["data"] is List) {
        return List<Map<String, dynamic>>.from(response.data["data"]);
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Error fetching grades");
    }
  }

  /// Fetch teaching subjects
  Future<List<Map<String, dynamic>>> getListingSubjects() async {
    try {
      final response = await _dio.get(Endpoints.fetchSubjects);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data["data"] is List) {
        return List<Map<String, dynamic>>.from(response.data["data"]);
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Error fetching subjects");
    }
  }

  Future<List<dynamic>> fetchWebinars() async {
    final response = await _dio.get("/webinars");
    return response.data;
  }

  Future<Map<String, dynamic>> fetchWebinar(int id) async {
    final response = await _dio.get("/webinars/$id");
    return response.data;
  }

  Future<Map<String, dynamic>> registerUser(int webinarId, int userId) async {
    final response = await _dio.post(
      "/webinars/$webinarId/register",
      data: {"user_id": userId},
    );
    return response.data;
  }

  Future<List<dynamic>> fetchUserWebinars(int userId) async {
    final response = await _dio.get("/users/$userId/webinars");
    return response.data;
  }

  // Future<Map<String, dynamic>> userLoginEmail(String idToken) async {
  //   final response = await _dio.post(
  //     "/user-login-email",
  //     data: {"idToken": idToken},
  //   );
  //   return response.data;
  // }

  Future<ApiResponse<Map<String, dynamic>>> userLoginEmail(
    String idToken,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.signInWithGoogle,
        data: json.encode({'idToken': idToken}),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'OTP verified successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid OTP',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyUserEmail(
    String idToken,
  ) async {
    try {
      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';

      if (token.isNotEmpty) setAuthToken(token);

      final response = await _dio.post(
        Endpoints.verifyWithGoogle,
        data: json.encode({'idToken': idToken}),
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Account verified successfully',
          data: responseData,
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Account verification failed',
          data: responseData,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> checkUserEmail(String idToken) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final response = await _dio.post(
      "/google-login-check",
      data: {"idToken": idToken},
    );
    return response.data;
  }

  // UserDataStore
  Future<Map<String, dynamic>> userDataStore() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final response = await _dio.post("/user-data-retrieve");
    return response.data;
  }

  Future<StudentModel> profileUserData() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);

    final response = await _dio.post("/user-data-retrieve");

    // Extract and map to StudentModel
    final data = response.data['data'];
    return StudentModel.fromJson(data);
  }

  Future<Map<String, dynamic>> applyReferralProvider(String data) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);

    final response = await _dio.post(
      "/apply-referral",
      data: {"referral_code": data},
    );

    return response.data;
  }

  Future<Map<String, dynamic>> takeReferral() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final response = await _dio.post("/take-referral");
    return response.data;
  }

  // Fetch top banners
  Future<List<TopBanner>> fetchTopBanners() async {
    await _loadAuth();
    final res = await _dio.get('/top-banners');
    if (res.statusCode == 200) {
      final data = res.data['data'] as List;
      return data.map((e) => TopBanner.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch banners');
    }
  }

  // ==============================
  // Fetch Class Detail
  // ==============================
  Future<Map<String, dynamic>> fetchClassDetail(String id) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate API delay

    return {
      'class_detail': {
        'id': id,
        'title': 'Flutter Mastery Bootcamp',
        'description':
            'A complete guide to mastering Flutter development — from basics to advanced topics.',
        'image':
            'https://cdn.dribbble.com/users/1626229/screenshots/11174104/flutter_intro.png',
      },
      'materials': [
        {
          'id': 1,
          'title': 'Introduction to Flutter',
          'file_url': 'https://example.com/flutter-intro.pdf',
        },
        {
          'id': 2,
          'title': 'State Management Overview',
          'file_url': 'https://example.com/state-management.pdf',
        },
      ],
      'classes': [
        {
          'id': '1',
          'title': 'Welcome & Setup',
          'status': 'completed',
          'date_time': '2025-10-01T10:00:00Z',
          'recorded_video': 'https://youtu.be/iLnmTe5Q2Qw',
          'join_link': '',
        },
        {
          'id': '2',
          'title': 'Widgets 101',
          'status': 'ongoing',
          'date_time': '2025-11-06T10:00:00Z',
          'join_link': 'https://meet.google.com/ufr-stwo-jjc',
          'recorded_video': '',
        },
        {
          'id': '3',
          'title': 'Animations & Transitions',
          'status': 'upcoming',
          'date_time': '2025-11-08T08:00:00Z',
          'join_link': '',
          'recorded_video': '',
        },
      ],
    };
  }

  /// Fetch all teachers, subjects, grades, boards
  // Future<Map<String, dynamic>> fetchAllSearchData() async {
  //   try {
  //     final res = await _dio.get('/search-data');
  //     if (res.statusCode == 200) {
  //       // Returns: {teachers: [...], subjects: [...], grades: [...], boards: [...]}
  //       return res.data;
  //     } else {
  //       throw Exception('Failed to fetch search data');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching search data: $e');
  //   }
  // }

  /// Fetch filtered search results
  /// filters = { 'teachers': [1,2], 'subjects':[1], 'grades':[2], 'boards':[1] }
  // Future<Map<String, dynamic>> searchResult(
  //   Map<String, List<int>> filters,
  // ) async {
  //   try {
  //     final res = await _dio.post('/search-result', data: filters);
  //     if (res.statusCode == 200) {
  //       return res.data; // e.g., {teachers:[...], subjects:[...], ...}
  //     } else {
  //       throw Exception('Failed to fetch filtered results');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching filtered results: $e');
  //   }
  // }

  /// Optional: Send follow-up info to CRM (user clicked an item)
  Future<void> followUp(int id, String type) async {
    try {
      await _dio.post('/crm-followup', data: {'id': id, 'type': type});
    } catch (e) {
      print('CRM follow-up failed: $e');
    }
  }

  Future<Map<String, dynamic>> fetchAllSearchData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'teachers': List.generate(
        10,
        (i) => {
          'id': i + 1,
          'name': 'Teacher ${i + 1}',
          'qualification': 'Qualification ${i + 1}',
          'image': 'https://via.placeholder.com/150',
        },
      ),
      'subjects': List.generate(
        10,
        (i) => {'id': i + 1, 'name': 'Subject ${i + 1}', 'icon': 'book'},
      ),
      'grades': List.generate(
        10,
        (i) => {'id': i + 1, 'name': 'Grade ${i + 1}'},
      ),
      'boards': List.generate(
        5,
        (i) => {'id': i + 1, 'name': 'Board ${i + 1}'},
      ),
    };
  }

  Future<Map<String, dynamic>> searchResult(
    Map<String, List<int>> filters,
  ) async {
    // Return fake filtered data based on selected IDs
    final allData = await fetchAllSearchData();

    Map<String, dynamic> filterList(String key) {
      final ids = filters[key] ?? [];
      if (ids.isEmpty) return allData[key];
      return allData[key].where((item) => ids.contains(item['id'])).toList();
    }

    return {
      'teachers': filterList('teachers'),
      'subjects': filterList('subjects'),
      'grades': filterList('grades'),
      'boards': filterList('boards'),
    };
  }

  Future<List<DropdownItem>> fetchDropdownData(String type) async {
    // Temporary dummy API simulation
    await Future.delayed(const Duration(milliseconds: 500));
    switch (type) {
      case 'grades':
        return [
          DropdownItem(id: 1, name: 'Grade 1'),
          DropdownItem(id: 2, name: 'Grade 2'),
          DropdownItem(id: 3, name: 'Grade 3'),
        ];
      case 'boards':
        return [
          DropdownItem(id: 1, name: 'CBSE'),
          DropdownItem(id: 2, name: 'ICSE'),
          DropdownItem(id: 3, name: 'State Board'),
        ];
      case 'subjects':
        return [
          DropdownItem(id: 1, name: 'Math'),
          DropdownItem(id: 2, name: 'Science'),
          DropdownItem(id: 3, name: 'English'),
        ];
      default:
        return [];
    }
  }

  // temporary: requested classes list
  Future<List<Map<String, dynamic>>> fetchRequestedClasses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        "id": 1,
        "requested_date": "2025-10-18",
        "to": "Grade 2 - Math",
        "status": "Pending",
        "notes": "Admin will call soon",
        "demo_class": "Scheduled for 2025-10-21",
      },
      {
        "id": 2,
        "requested_date": "2025-10-17",
        "to": "Grade 3 - Science",
        "status": "Approved",
        "notes": "Follow-up done",
        "demo_class": "Completed",
      },
    ];
  }

  Future<List<dynamic>> fetchSocialLinks() async {
    try {
      final response = await _dio.get(
        '/bottom-social-links',
      ); // ✅ correct endpoint
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      print('⚠️ fetchSocialLinks failed: $e');
    }
    return []; // ✅ Always return a list, even if empty
  }

  Future<Map<String, dynamic>> fetchConnectData() async {
    try {
      final response = await _dio.get('/social-links');

      if (response.statusCode == 200) {
        final data = response.data;

        return {
          "socials": data['socials'] ?? [],
          "contact": data['contact'] ?? {},
        };
      }
    } catch (e) {
      print("⚠️ fetchConnectData error: $e");
    }

    // Default fallback
    return {"socials": [], "contact": {}};
  }

  Future<List<dynamic>> fetchCommunityLinks() async {
    try {
      final response = await _dio.get('/community-links');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == true && data['data'] != null) {
          return data['data']; // return list
        }
      }
    } catch (e) {
      print('⚠️ fetchCommunityLinks failed: $e');
    }

    return [];
  }

  // ------------------------------
  // 🔹 Common request handler
  // ------------------------------
  Future<Map<String, dynamic>?> _handleRequest(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else {
          return jsonDecode(response.data);
        }
      } else {
        return {'status': false, 'message': 'Unexpected server response'};
      }
    } on DioException catch (e) {
      return {
        'status': false,
        'message': e.response?.data?['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      return {'status': false, 'message': 'Something went wrong: $e'};
    }
  }

  // ------------------------------
  // 🔹 Fetch Dropdown Data
  // ------------------------------

  Future<List<String>> fetchGrades() async {
    final res = await _handleRequest(() => _dio.get('/grades'));
    if (res?['status'] == true && res?['data'] != null) {
      final List<dynamic> data = res!['data'];
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<String>> fetchBoards() async {
    final res = await _handleRequest(() => _dio.get('/boards'));
    if (res?['status'] == true && res?['data'] != null) {
      final List<dynamic> data = res!['data'];
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  // Logout API
  Future<void> logout() async {
    try {
      await _loadAuth();
      final res = await _dio.post('/logout');

    } catch (_) {}
  }

  // Delete account request
  Future<bool> requestDeleteAccount() async {
    try {
      await _loadAuth();
      final res = await _dio.post('/account/delete-request');

      return res.data['status'] == true;

    } catch (_) {
      return false;
    }
  }

  Future<TeacherPerformanceModel?> fetchTeacherPerformance(
    String filter,
  ) async {
    try {
      await _loadAuth();
      final response = await _dio.get(
        '/teacher/performance',
        queryParameters: {"filter": filter},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return TeacherPerformanceModel.fromJson(response.data);
      }
    } catch (e) {
      print("⚠️ Performance API error: $e");
    }
    return null;
  }

  // Future<List<String>> fetchSubjects() async {
  //   final res = await _handleRequest(() => _dio.get('/subjects'));
  //   if (res?['status'] == true && res?['data'] != null) {
  //     final List<dynamic> data = res!['data'];
  //     return data.map((e) => e.toString()).toList();
  //   }
  //   return [];
  // }

  // Future<List<Subject>> fetchSubjects() async {
  //   try {
  //     final response = await _dio.get('/subjects');
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       if (data is List) {
  //         return data.map((json) => Subject.fromJson(json)).toList();
  //       } else if (data is Map && data['data'] is List) {
  //         return (data['data'] as List)
  //             .map((json) => Subject.fromJson(json))
  //             .toList();
  //       }
  //     }
  //     throw Exception("Unexpected response format");
  //   } catch (e) {
  //     print("❌ Error fetching subjects: $e");
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> fetchSubjects() async {
    final res = await _dio.get('/subjects');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> fetchCourseBanners() async {
    final res = await _dio.get('/course-banners');
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> fetchProvideCourses() async {
    final res = await _dio.get('/provide-courses');
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<String>> fetchCategories() async {
    final res = await _handleRequest(() => _dio.get('/categories'));
    if (res?['status'] == true && res?['data'] != null) {
      final List<dynamic> data = res!['data'];
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<String>> fetchSkills() async {
    final res = await _handleRequest(() => _dio.get('/skills'));
    if (res?['status'] == true && res?['data'] != null) {
      final List<dynamic> data = res!['data'];
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<dynamic> fetchMyClasses() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';
    if (token.isNotEmpty) setAuthToken(token);
    final res = await _dio.post('/my-classes');
    return res.data;
  }

  // Future<Map<String, dynamic>?> requestTopBannerSection(String bannerId) async {
  //   try {
  //     final response = await _dio.post(
  //       'api/top-banner/submit',
  //       data: {'banner_id': bannerId},
  //     );
  //     if (response.statusCode == 200) {
  //       return response.data; // directly return the parsed response
  //     } else {
  //       return {'status': false, 'message': 'Unexpected status: ${response.statusCode}'};
  //     }
  //   } catch (e) {
  //     print('⚠️ requestTopBannerSection failed: $e');
  //     return {'status': false, 'message': 'Error occurred: $e'};
  //   }
  // }

  // Future<Map<String, dynamic>?> requestTeacherClass(String bannerId) async {
  //   try {
  //     final response = await _dio.post(
  //       'api/request-teacher-class/submit',
  //       data: {'banner_id': bannerId},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response.data; // directly return the parsed response
  //     } else {
  //       return {'status': false, 'message': 'Unexpected status: ${response.statusCode}'};
  //     }
  //   } catch (e) {
  //     print('⚠️ requesting failed: $e');
  //     return {'status': false, 'message': 'Error occurred: $e'};
  //   }
  // }
  //
  // Future<Map<String, dynamic>?> requestForm(String bannerId) async {
  //   try {
  //     final response = await _dio.post(
  //       'api/request-form/submit',
  //       data: {'banner_id': bannerId},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response.data; // directly return the parsed response
  //     } else {
  //       return {'status': false, 'message': 'Unexpected status: ${response.statusCode}'};
  //     }
  //   } catch (e) {
  //     print('⚠️ requesting failed: $e');
  //     return {'status': false, 'message': 'Error occurred: $e'};
  //   }
  // }
  //
  //
  // Future<Map<String, dynamic>?> requestCourse(String courseId) async {
  //   try {
  //     final response = await _dio.post(
  //       'api/request-teacher-class/submit',
  //       data: {'banner_id': courseId},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return response.data; // directly return the parsed response
  //     } else {
  //       return {'status': false, 'message': 'Unexpected status: ${response.statusCode}'};
  //     }
  //   } catch (e) {
  //     print('⚠️ requesting failed: $e');
  //     return {'status': false, 'message': 'Error occurred: $e'};
  //   }
  // }

  // 🔹 Top Banner Submit
  Future<Map<String, dynamic>?> requestTopBannerSection(String bannerId) async {
    return _submitRequest('/top-banner/submit', {'banner_id': bannerId});
  }

  // 🔹 Request Teacher Class (Form data)
  // Future<Map<String, dynamic>?> requestTeacherClass(
  //   Map<String, dynamic> formData,
  // ) async {
  //   // formData can include: name, email, subject_id, etc.
  //   return _submitFormRequest('/request-teacher-class/submit', formData);
  // }

  // 🔹 General Request Form (Form data)
  Future<Map<String, dynamic>?> submitRequestForm(
    Map<String, dynamic> formData,
  ) async {
    return _submitFormRequest('/request-form/submit', formData);
  }

  Future<Map<String, dynamic>?> submitTeacherClassRequest(
    Map<String, dynamic> formData,
  ) async {
    return _submitFormRequest('/request-teacher-class/submit', formData);
  }

  Future<Map<String, dynamic>?> requestCourseEnrollment(String bannerId) async {
    return _submitRequest('/request-course/submit', {'banner_id': bannerId});
  }

  Future<Map<String, dynamic>?> requestSubjectClassBooking(
    Map<String, dynamic> formData,
  ) async {
    return _submitFormRequest('/request-subject-class/submit', formData);
  }

  Future<List<Grade>> fetchGradesWithBoardsAndSubjects() async {
    try {
      await _loadAuth();
      final response = await _dio.get('/grades');
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['status'] == true) {
        final data = response.data['grades'] as List;
        return data
            .map((e) => Grade.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching grades: $e');
      return [];
    }
  }

  // 🔹 Course Request (normal JSON body)
  Future<Map<String, dynamic>?> requestCourse(String courseId) async {
    return _submitRequest('/request-course/submit', {'course_id': courseId});
  }

  // Future<List<String>> fetchGrades() async {
  //   final response = await _dio.get('/grades');
  //   if (response.statusCode == 200 && response.data['status'] == true) {
  //     return List<String>.from(response.data['data']);
  //   }
  //   return [];
  // }
  //
  // Future<List<String>> fetchBoards() async {
  //   final response = await _dio.get('/boards');
  //   if (response.statusCode == 200 && response.data['status'] == true) {
  //     return List<String>.from(response.data['data']);
  //   }
  //   return [];
  // }

  // Future<List<String>> fetchSubjects() async {
  //   final response = await _dio.get('/subjects');
  //   if (response.statusCode == 200 && response.data['status'] == true) {
  //     return List<String>.from(response.data['data']);
  //   }
  //   return [];
  // }

  // Future<List<Map<String, dynamic>>> fetchGrades() async {
  //   final res = await _dio.get('/grades');
  //   return List<Map<String, dynamic>>.from(res.data['data']);
  // }

  Future<Map<String, dynamic>> fetchOptionsByGrade(String gradeCode) async {
    final res = await _dio.get('/options/$gradeCode');
    return res.data['data'];
  }

  Future<List<String>> fetchSubjectsByBoard(int id) async {
    final res = await _dio.get('/subjects/$id');
    return List<String>.from(res.data['data']);
  }

  Future<List<String>> fetchSkillsByCategory(int id) async {
    final res = await _dio.get('/skills/$id');
    return List<String>.from(res.data['data']);
  }

  // ------------------------------------------
  // ✅ Common helper for normal JSON request
  // ------------------------------------------
  Future<Map<String, dynamic>?> _submitRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';

      if (token.isNotEmpty) {
        setAuthToken(token);
      } else {
        return {'status': false, 'message': 'Token not Matched'};
      }

      final response = await _dio.post(endpoint, data: data);

      if (response.statusCode == 200) {
        return response.data;
      }
      return {
        'status': false,
        'message': 'Unexpected status: ${response.statusCode}',
      };
    } catch (e) {
      print('⚠️ Request failed [$endpoint]: $e');
      return {'status': false, 'message': 'Error occurred: $e'};
    }
  }

  // ------------------------------------------
  // ✅ Common helper for multipart/form-data
  // ------------------------------------------
  Future<Map<String, dynamic>?> _submitFormRequest(
    String endpoint,
    Map<String, dynamic> formData,
  ) async {
    try {
      FormData data = FormData.fromMap(formData);
      final box = await Hive.openBox('app_storage');
      final token = box.get('auth_token') ?? '';

      if (token.isNotEmpty) {
        setAuthToken(token);
      } else {
        return {'status': false, 'message': 'Token not Matched'};
      }

      final response = await _dio.post(endpoint, data: data);

      if (response.statusCode == 200) {
        return response.data;
      }
      return {
        'status': false,
        'message': 'Unexpected status: ${response.statusCode}',
      };
    } catch (e) {
      print('⚠️ Form request failed [$endpoint]: $e');
      return {'status': false, 'message': 'Error occurred: $e'};
    }
  }

  Future<List<dynamic>> fetchClassRequests() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);

    final response = await _dio.post("/requested-classes");

    if (response.statusCode == 200 && response.data['data'] != null) {
      return response.data['data']; // assuming Laravel returns {data: [..]}
    } else if (response.data is List) {
      // some APIs return a plain list
      return response.data;
    } else {
      throw Exception("Unexpected API response");
    }
  }

  Future<Map<String, dynamic>> fetchWalletData() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);

    final response = await _dio.post("/my-wallet");

    return response.data;
  }

  Future<Map<String, dynamic>> convertToRupees(double amount) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);

    final response = await _dio.post(
      '/wallet/convert-to-rupees',
      data: {'amount': amount},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> transferToBank(double amount) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);

    final response = await _dio.post(
      '/wallet/transfer-to-bank',
      data: {'amount': amount},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> recordReferralShare(
    String code, {
    String method = 'share_sheet',
  }) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final res = await _dio.post(
      '/referral/share',
      data: {'code': code, 'method': method},
    );
    return res.data;
  }

  Future<Map<String, dynamic>> sendInvites(
    List<Map<String, dynamic>> contacts,
    String code,
  ) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final res = await _dio.post(
      '/referral/send-invites',
      data: {'contacts': contacts, 'code': code},
    );
    return res.data;
  }

  Future<Map<String, dynamic>> recordReferralClick(String code) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final res = await _dio.post('/referral/click', data: {'code': code});
    return res.data;
  }

  Future<Map<String, dynamic>> applyReferralOnRegister(
    String code,
    Map<String, dynamic> signupData,
  ) async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) setAuthToken(token);
    final res = await _dio.post(
      '/referral/register',
      data: {'referral_code': code, ...signupData},
    );
    return res.data;
  }

  Future<NotificationResponse> fetchNotifications() async {
    final res = await _dio.get("/notifications");

    return NotificationResponse.fromJson(res.data);
  }

  Future<bool> markNotificationRead(int id) async {
    final res = await _dio.post("/notifications/mark-read/$id");
    return res.data["status"] == 200;
  }
}

class DropdownItem {
  final int id;
  final String name;

  DropdownItem({required this.id, required this.name});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(id: json['id'], name: json['name']);
  }
}
