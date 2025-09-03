// lib/controller/auth_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../services/api_service.dart';
import '../providers/auth_state.dart';

// Provider for the API service
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(client: http.Client());
});

// Provider for the auth controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final apiService = ref.watch(authApiServiceProvider);
    return AuthController(apiService: apiService);
  },
);

class AuthController extends StateNotifier<AuthState> {
  final AuthApiService apiService;
  Timer? _cooldownTimer;

  AuthController({required this.apiService}) : super(const AuthState());

  // Send OTP method
  Future<bool> sendOtp(String phoneNumber) async {
    // Validate phone number
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      state = state.copyWith(
        error: 'Please enter a valid phone number',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      phoneNumber: phoneNumber,
    );

    print(phoneNumber);

    try {
      final response = await apiService.sendOtp(phoneNumber);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          resendCount: 0, // Reset resend count on successful send
          canResend: true,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Verify OTP method
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
        // Extract token from response if available

        final token =
            response.data?['token'] ?? response.data?['data']?['token'];

        final user = response.data?['user'] ?? response.data?['user']?['token'];

        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          authToken: token,
          error: null,
          userData: user,
        );

        return true;

      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Resend OTP method with limitations
  Future<bool> resendOtp() async {
    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'Phone number not found');
      return false;
    }

    // Check resend limitations
    if (state.resendCount >= 2 && !state.canResend) {
      state = state.copyWith(error: 'Please wait before resending');
      return false;
    }

    if (state.resendCount >= 3) {
      // Start 5-minute cooldown after 3 attempts
      state = state.copyWith(
        canResend: false,
        resendCooldown: 300, // 5 minutes in seconds
      );

      // Start countdown timer
      _startCooldownTimer();

      state = state.copyWith(
        error: 'Maximum attempts reached. Please wait 5 minutes.',
      );
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
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Send signup OTP method
  Future<bool> signupSendOtp(String phoneNumber) async {
    // Validate phone number
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      state = state.copyWith(
        error: 'Please enter a valid phone number',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      phoneNumber: phoneNumber,
    );

    try {
      final response = await apiService.signupSendOtp(phoneNumber);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          resendCount: 0, // Reset resend count on successful send
          canResend: true,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Verify OTP method
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
      final response = await apiService.verifyOtp(state.phoneNumber!, otp);

      if (response.success) {
        // Extract token from response if available
        final token =
            response.data?['token'] ?? response.data?['data']?['token'];

        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          authToken: token,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> getUserData() async {
    state = state.copyWith(isLoading: true, error: null);

    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'Phone number not found');
      return false;
    }

    try {
      final response = await apiService.getUserData(state.phoneNumber!);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          userData: response.data, // ✅ Save user data in state
        );
        print(response.data);
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  // Start cooldown timer
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

  // Clear error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  // Reset state (for logout)
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
