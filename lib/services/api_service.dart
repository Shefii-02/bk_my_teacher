import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/endpoints.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class AuthApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

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
      String phoneNumber, String otp) async {
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

  Future<ApiResponse<Map<String, dynamic>>> resendOtp(String phoneNumber) async {
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
      String phoneNumber) async {
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
      String phoneNumber, String otp) async {
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
      return ApiResponse(success: false, message: "Network error: ${e.message}");
    }
  }
}
