import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final String baseUrl = "https://bookmyteacher.shefii.com/api";

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final response = await http.post(
      Uri.parse("$baseUrl/send-otp"),
      body: {"mobile": mobile},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send OTP");
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      body: {"mobile": mobile, "otp": otp},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to verify OTP");
    }
  }
}
