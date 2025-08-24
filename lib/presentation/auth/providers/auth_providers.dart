import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../repository/auth_repository.dart';

// STATE
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? data;

  AuthState({this.isLoading = false, this.error, this.data});

  AuthState copyWith({bool? isLoading, String? error, Map<String, dynamic>? data}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data,
    );
  }
}

// PROVIDERS
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(apiServiceProvider)));
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(authRepositoryProvider)));

// NOTIFIER
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  AuthNotifier(this.repository) : super(AuthState());

  Future<void> sendOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await repository.sendOtp(mobile);
      state = state.copyWith(isLoading: false, data: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await repository.verifyOtp(mobile, otp);
      state = state.copyWith(isLoading: false, data: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
