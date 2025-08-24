import '../../../services/api_service.dart';

class AuthRepository {
  final ApiService apiService;
  AuthRepository(this.apiService);

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    return await apiService.sendOtp(mobile);
  }

  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    return await apiService.verifyOtp(mobile, otp);
  }
}
