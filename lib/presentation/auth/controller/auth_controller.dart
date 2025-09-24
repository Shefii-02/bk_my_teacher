// lib/controller/auth_controller.dart
import 'dart:async';
import 'package:BookMyTeacher/services/user_check_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_state.dart';
import '../../../services/api_service.dart';

// Provider for the API service
final ApiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(); // ✅ Now using Dio-based service (no http.Client)
});

// Provider for the auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
      (ref) {
    final apiService = ref.watch(ApiServiceProvider);
    return AuthController(apiService: apiService);
  },
);

class AuthController extends StateNotifier<AuthState> {
  final ApiService apiService;
  Timer? _cooldownTimer;

  AuthController({required this.apiService}) : super(const AuthState());

  // Send OTP
  Future<bool> sendOtp(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      state = state.copyWith(
        error: 'Please enter a valid phone number',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, phoneNumber: phoneNumber);

    try {
      final response = await apiService.sendOtp(phoneNumber);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          resendCount: 0,
          canResend: true,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'Phone number not found');
      return false;
    }

    if (otp.isEmpty || otp.length != 4) {
      state = state.copyWith(error: 'Please enter a valid 4-digit OTP');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.verifyOtp(state.phoneNumber!, otp);

      if (response.success) {
        final token = response.data?['token'] ?? response.data?['data']?['token'];
        final user  = response.data?['user'] ?? response.data?['data']?['user'];

        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          authToken: token,
          userData: user,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'Phone number not found');
      return false;
    }

    if (state.resendCount >= 2 && !state.canResend) {
      state = state.copyWith(error: 'Please wait before resending');
      return false;
    }

    if (state.resendCount >= 3) {
      state = state.copyWith(
        canResend: false,
        resendCooldown: 300,
        error: 'Maximum attempts reached. Please wait 5 minutes.',
      );
      _startCooldownTimer();
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.resendOtp(state.phoneNumber!);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          resendCount: state.resendCount + 1,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Signup OTP send
  Future<bool> signupSendOtp(String phoneNumber) async {
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      state = state.copyWith(
        error: 'Please enter a valid phone number',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, phoneNumber: phoneNumber);

    try {
      final response = await apiService.signupSendOtp(phoneNumber);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          resendCount: 0,
          canResend: true,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Signup verify OTP
  Future<bool> signupVerifyOtp(String otp) async {
    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'Phone number not found');
      return false;
    }

    if (otp.isEmpty || otp.length != 4) {
      state = state.copyWith(error: 'Please enter a valid 4-digit OTP');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await apiService.signupVerifyOtp(state.phoneNumber!, otp);

      if (response.success) {
        final token = response.data?['token'] ?? response.data?['data']?['token'];

        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          authToken: token,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Get user data
  Future<bool> getUserData() async {
    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'Phone number not found');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await UserCheckService().getUserData(state.phoneNumber!);

      if (response.success) {
        state = state.copyWith(isLoading: false, userData: response.data);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Cooldown timer
  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown > 0) {
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      } else {
        state = state.copyWith(canResend: true);
        timer.cancel();
      }
    });
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void reset() {
    _cooldownTimer?.cancel();
    state = const AuthState();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
