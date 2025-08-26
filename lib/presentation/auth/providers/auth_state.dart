// lib/controller/auth_state.dart
import 'package:flutter/foundation.dart';

@immutable
class AuthState {
  final bool isLoading;
  final String? error;
  final int resendCount;
  final bool canResend;
  final int resendCooldown;
  final String? phoneNumber;
  final String? authToken;
  final bool isVerified;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.resendCount = 0,
    this.canResend = true,
    this.resendCooldown = 0,
    this.phoneNumber,
    this.authToken,
    this.isVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    int? resendCount,
    bool? canResend,
    int? resendCooldown,
    String? phoneNumber,
    String? authToken,
    bool? isVerified,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      resendCount: resendCount ?? this.resendCount,
      canResend: canResend ?? this.canResend,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      authToken: authToken ?? this.authToken,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() {
    return 'AuthState{isLoading: $isLoading, error: $error, resendCount: $resendCount, canResend: $canResend, resendCooldown: $resendCooldown, phoneNumber: $phoneNumber, isVerified: $isVerified}';
  }
}