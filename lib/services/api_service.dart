// lib/data/api/auth_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:app/core/constants/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class AuthApiService {
  static const String baseUrl = Endpoints.base; // Replace with your API URL

  final http.Client client;

  AuthApiService({required this.client});

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phoneNumber) async {
    print(phoneNumber);
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': phoneNumber,'type' : 'first'}),
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);
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
    } on http.ClientException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Request timeout. Please try again.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': phoneNumber, 'otp': otp}),
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

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
    } on http.ClientException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Request timeout. Please try again.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOtp(String phoneNumber) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phoneNumber,'type' : 'resend'}),
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

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
    } on http.ClientException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Request timeout. Please try again.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}


// import 'dart:convert';
// import 'package:app/core/constants/endpoints.dart';
// import 'package:http/http.dart' as http;
//
// class ApiService {
//   static const String baseUrl = Endpoints.base;
//
//   Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
//     final url = Uri.parse("$baseUrl/$endpoint");
//     final response = await http.post(url,
//         body: jsonEncode(body),
//         headers: {"Content-Type": "application/json"});
//
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed request: ${response.body}");
//     }
//   }
// }
