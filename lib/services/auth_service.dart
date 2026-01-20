import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_service.dart';

class AuthService {
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
        scopeHint: ['email','profile'],
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
      final response = await _apiService.userLoginEmail(idToken,email);

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
}
