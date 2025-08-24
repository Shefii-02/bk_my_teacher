import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController {
  final AuthRepository _repository;

  AuthController(this._repository);

  Future<String> sendOtp(String mobile) async {
    final res = await _repository.sendOtp(mobile);
    return res['message'] ?? "OTP sent successfully!";
  }

  Future<String> verifyOtp(String mobile, String otp) async {
    final res = await _repository.verifyOtp(mobile, otp);
    if (res['success'] == true) {
      final token = res['token'];
      // Save token in secure storage if needed
      return "Login successful! Token: $token";
    } else {
      throw Exception(res['message'] ?? "OTP verification failed");
    }
  }
}
