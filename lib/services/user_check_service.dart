import 'dart:convert';

import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';

class UserCheckService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      // connectTimeout: 30000, // 30 seconds
      // receiveTimeout: 30000,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Add token dynamically to the Dio instance
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Check if user exists (still POST body, depends on your backend)
  Future<bool> isUserValid(String userId, String accType) async {
    try {
      final response = await _dio.post(
        Endpoints.checkUser,
        data: {"user_id": userId, "acc_type": accType},
      );

      if (response.statusCode == 200) {
        return response.data["exists"] == true;
      }
      return false;
    } catch (e) {
      print("❌ Error checking user: $e");
      return false;
    }
  }

  /// Fetch user data using Sanctum token
  Future<Map<String, dynamic>?> fetchUserData(String token) async {
    try {
      setAuthToken(token);
      final response = await _dio.post(Endpoints.getUserDetails);

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("❌ Error fetching user data: $e");
      return null;
    }
  }

  /// Set token for user (login)
  Future<String?> setUserToken(String userId) async {
    try {
      final response = await _dio.post(
        Endpoints.setUserToken,
        data: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] as String?;
        if (token != null) setAuthToken(token); // dynamically update header
        return token;
      }
      return null;
    } catch (e) {
      print("❌ Error setting user token: $e");
      return null;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserData(
    String phoneNumber,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.userDetails,
        data: json.encode({'mobile': phoneNumber}),
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ApiResponse(
          success: false,
          message: 'Request timeout. Please try again.',
        );
      } else if (e.response != null) {
        return ApiResponse(
          success: false,
          message: e.response?.data['message'] ?? 'Server error',
          data: e.response?.data,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
