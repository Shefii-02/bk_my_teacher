// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// final FirebaseAuth _auth = FirebaseAuth.instance;
// // final GoogleSignIn _googleSignIn =
// final _googleSignIn = GoogleSignIn(scopes: ['email']);
//
// Future<User?> signInWithGoogle() async {
//   try {
//     // Trigger the authentication flow
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//     // final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
//     //     .authenticate();
//
//     if (googleUser == null) {
//       // The user canceled the sign-in
//       return null;
//     }
//
//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;
//     // final GoogleSignInAuthentication googleAuth = googleUser.authentication;
//     final credential = GoogleAuthProvider.credential(
//       idToken: googleAuth.idToken,
//     );
//     print("**************x");
//     print(credential);
//     print("**************x");
//
//     // Create a new credential
//     // final credential = GoogleAuthProvider.credential(
//     //   accessToken: googleAuth.accessToken,
//     //   idToken: googleAuth.idToken,
//     // );
//
//     // Sign in to Firebase with the credential
//     final UserCredential userCredential = await _auth.signInWithCredential(
//       credential,
//     );
//     return userCredential.user;
//   } catch (e) {
//     // Handle error
//     print(e.toString());
//     return null;
//   }
// }
