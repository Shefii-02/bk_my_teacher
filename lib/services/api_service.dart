import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../core/constants/endpoints.dart';

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
      print(responseData);
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

  Future<ApiResponse<Map<String, dynamic>>> userLoginEmail(String idToken) async {
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



}
