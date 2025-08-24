import 'dart:convert';

import 'package:dio/dio.dart';
import '../core/constants/endpoints.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  final String baseUrl = Endpoints.base;

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final url = Uri.parse("$baseUrl/send-otp");
    print(mobile);
    final requestData = {"mobile": '8075261300'};

    print("Calling URL: $url");
    print("With Data: $requestData");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed: ${response.body}");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  // Request OTP
  // Future<Map<String, dynamic>> sendOtp(String mobile) async {
  //   try {
  //     final response = await _dio.post(
  //       Endpoints.sendOtp,
  //       data: {"mobile": mobile},
  //     );
  //
  //     if (response.data is Map<String, dynamic>) {
  //       return response.data;
  //     } else {
  //       throw Exception("Unexpected response format: ${response.data}");
  //     }
  //   } on DioException catch (e) {
  //     print(e.response);
  //     print("******** API Error ********");
  //     print("Status Code: ${e.response?.statusCode}");
  //     print("Error Data: ${e.response?.data}");
  //     print("***************************");
  //     throw Exception(e.response?.data["message"] ?? "Something went wrong");
  //   }
  // }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _dio.post(
        Endpoints.verifyOtp,
        data: {"mobile": mobile, "otp": otp},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Invalid OTP");
    }
  }
}
