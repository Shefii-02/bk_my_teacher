import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In (v7.2.0)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // UserCredential? userCred = await _authService
            //     .signInWithGoogleFirebase();
            // if (userCred != null) {
            //   final user = userCred.user;
            //   print(user);
            //   print("✅ Signed in: ${user?.displayName}");
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('Welcome, ${user?.displayName}!')),
            //   );
            // } else {
            //   print("❌ Sign-in failed");
            // }
          },
          child: const Text("Sign in with Google"),
        ),
      ),
    );
  }
}
