// ✅ Correct — copy this into your project file
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../model/apple_auth_result.dart';
import 'auth_service.dart';

class AppleAuthService {
  static Future<AppleAuthResult?> signIn() async {   // ← AppleAuthResult? not String?
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final uid   = credential.userIdentifier ?? '';
      final prefs = await SharedPreferences.getInstance();

      String? savedEmail = prefs.getString('apple_email_$uid');
      String? savedName  = prefs.getString('apple_name_$uid');

      if (credential.email != null && credential.email!.isNotEmpty) {
        await prefs.setString('apple_email_$uid', credential.email!);
        savedEmail = credential.email;
      }

      final fullName = [credential.givenName, credential.familyName]
          .where((e) => e != null && e.isNotEmpty)
          .join(' ');

      if (fullName.isNotEmpty) {
        await prefs.setString('apple_name_$uid', fullName);
        savedName = fullName;
      }

      final nameParts = (savedName ?? '').trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : null;
      final lastName  = nameParts.length > 1  ? nameParts.last  : null;

      final payload = <String, String?>{
        'identity_token'  : credential.identityToken,
        'user_identifier' : uid,
        'email'           : savedEmail,
        'first_name'      : firstName,
        'last_name'       : lastName,
      };

      final result = await AuthService().appleEmailIdCheckLogin(payload);

      if (result == null) throw Exception('Null response from server');
print(result);

      return result; // ✅ AppleAuthResult — has .status .message .token .user

    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    } catch (e) {
      print('🍎 Apple Sign-In error: $e');
      rethrow;
    }
  }
}