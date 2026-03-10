import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

import '../core/constants/endpoints.dart';
import '../model/apple_auth_result.dart';
import '../presentation/auth/view/signin_screen.dart';
import 'api_service.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // 🔹 Add auth token to header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ---------------------------------------------------------------------------
  // 🔹 COMMON — Load token & add in header
  // ---------------------------------------------------------------------------
  Future<void> _loadAuth() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;
  final ApiService _apiService = ApiService();

  AuthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
    } catch (e) {
      print("Google Sign-In init failed: $e");
    }
  }

  /// ✅ Sign in with Google (Firebase compatible)
  Future<UserCredential?> signInWithGoogleFirebase() async {
    await _initialize();

    try {
      // Start authentication flow
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Fetch tokens from the account
      final tokens = account.authentication; // sync in v7
      print("tokens: $tokens");

      final email = account.email;
      final idToken = tokens.idToken;
      print("tokens: $idToken");

      if (idToken == null) {
        throw Exception("Missing Google tokens");
      }

      // final accessToken = tokens.accessToken;
      final response = await _apiService.userLoginEmail(idToken, email);

      print('++++++++++++++++++++++++++++=');
      print('Decoded data: ${response.data}');
      print('Message: ${response.message}');
      print('Success: ${response.success}');

      if (response.success == 'success') {
        print('Successfull respinse');
        //   // Build Firebase credential
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        //   // print('credential : $credential');
        //   // Sign in with Firebase
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        print('userCredential : $userCredential');
        return userCredential;
      } else {
        return null;
      }
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }

  Future<UserCredential?> verifyWithGoogleFirebase() async {
    await _initialize();

    try {
      // Start authentication flow
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // Fetch tokens from the account
      final tokens = account.authentication; // sync in v7
      print("tokens: $tokens");

      final idToken = tokens.idToken;
      print("tokens: $idToken");

      if (idToken == null) {
        throw Exception("Missing Google tokens");
      }

      // final accessToken = tokens.accessToken;
      final data = await _apiService.checkUserEmail(idToken);
      // final data = await checkUserEmail(idToken);

      if (data['status'] == 'success') {
        print("✅ success $data");
        // Build Firebase credential
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        // print('credential : $credential');
        // Sign in with Firebase
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        print('userCredential : $userCredential');
        return userCredential;
      } else {
        return null;
      }
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }

  /// 🔄 Attempt silent sign-in (no popup)
  // Future<User?> trySilentSignIn() async {
  //   await _initialize();
  //   try {
  //     final result = _googleSignIn.attemptLightweightAuthentication();
  //     final GoogleSignInAccount? account =
  //     result is Future ? await result : result as GoogleSignInAccount?;
  //
  //     if (account == null) return null;
  //
  //     final tokens = account.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       idToken: tokens.idToken,
  //       accessToken: tokens.accessToken,
  //     );
  //
  //     final userCredential =
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     return userCredential.user;
  //   } catch (e) {
  //     print("Silent sign-in failed: $e");
  //     return null;
  //   }
  // }
  //
  // /// 🚪 Sign out user
  // Future<void> signOut() async {
  //   await _googleSignIn.signOut();
  //   await FirebaseAuth.instance.signOut();
  // }

  // ── AuthService ──
  Future<AppleAuthResult?> appleEmailIdCheckLogin(
    Map<String, String?> payload,
  ) async {
    await _loadAuth();
    try {
      final response = await _dio.post(
        "${Endpoints.base}/apple-sign-in",
        data: {
          'idToken': payload['identity_token'],
          'email': payload['email'],
          'first_name': payload['first_name'],
          'last_name': payload['last_name'],
          'user_identifier': payload['user_identifier'],
        },
      );
      // ✅ Parse here — return AppleAuthResult not raw Response
      return AppleAuthResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('appleEmailIdCheckLogin error: $e');
      return null;
    }
  }
}
