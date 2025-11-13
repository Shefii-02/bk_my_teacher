import 'package:BookMyTeacher/presentation/widgets/show_success_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../providers/user_provider.dart';
import '../auth/controller/auth_controller.dart';

class VerifyAccountPopup extends ConsumerStatefulWidget {
  final VoidCallback onVerified;
  const VerifyAccountPopup({super.key, required this.onVerified});

  @override
  ConsumerState<VerifyAccountPopup> createState() => _VerifyAccountPopupState();
}

class _VerifyAccountPopupState extends ConsumerState<VerifyAccountPopup> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.signOut(); // Clean session
      _isInitialized = true;
      debugPrint("✅ Google Sign-In initialized");
    } catch (e) {
      debugPrint("❌ Google Sign-In initialization failed: $e");
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    await _initializeGoogleSignIn();
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? account = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      if (account == null) {
        // User cancelled sign-in
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication tokens = await account.authentication;
      final idToken = tokens.idToken;

      if (idToken == null) throw Exception("No ID token received");

      debugPrint("✅ Received Google ID Token: $idToken");

      // ✅ Send ID token to backend for verification
      final authController = ref.read(authControllerProvider.notifier);
      final verified = await authController.verifyWithGoogleFirebase(idToken);

      if (!verified) {
        final error = ref.read(authControllerProvider).error;
        if (error != null && mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
        setState(() => _isLoading = false);
        return;
      }


      if (!mounted) return;

      showSuccessAlert(
        context,
        title: "Verified!",
        subtitle: "Account verified successfully",
        color: Colors.green,
        timer: 2,
        showButton: false,
      );

      Future.delayed(const Duration(seconds: 3), () async {
        // Code to be executed after 3 seconds
        await ref.read(userProvider.notifier).loadUser();
      });



      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("✅ Account verified successfully")),
      // );

      widget.onVerified();
    } catch (e) {

      debugPrint("❌ Google Account verification error: $e");
      if (mounted) {
        showSuccessAlert(
          context,
          title: "Verified!",
          subtitle: "Account verification failed",
          color: Colors.green,
          timer: 2,
          showButton: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user,
                    size: 80, color: Colors.blueAccent),
                const SizedBox(height: 16),
                const Text(
                  'Verify your email account',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please verify your account using Google to continue.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.lock_person_rounded),
                  label: const Text('Verify with Google Account'),
                  onPressed: () => _handleGoogleSignIn(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
