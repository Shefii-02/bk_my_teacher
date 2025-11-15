import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/app_config.dart';
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/launch_status_service.dart';
import '../controller/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isChecked = false;
  String _selectedCode = "+91";
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;


  void _showTopPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 60, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Login or Sign In Instruction",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    "",
                    // "This is your offcanvas-top style popup with animation. "
                    //     "You can add any content here.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim),
          child: child,
        );
      },
    );
  }

  // Update your SignInScreen's send OTP method:
  Future<void> _sendOtp() async {
    if (_isLoading) return;
    // if (!_isChecked) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please accept Terms and Conditions"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit mobile number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // ⏳ Show loader

    // _selectedCode +
    final fullPhoneNumber = _phoneController.text;
    final authController = ref.read(authControllerProvider.notifier);

    // Clear any previous errors
    authController.clearError();
    try {
      final success = await authController.sendOtp(fullPhoneNumber);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP Sent Successfully..."),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to verification screen with phone number
        context.go(
          '/verification-screen',
          extra: {'phoneNumber': fullPhoneNumber},
        );
      } else {
        // Error is already set in the state, we can show it
        final error = ref.read(authControllerProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // ✅ Hide loader
    }
  }

  final AuthService _authService = AuthService();

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
    } catch (e) {
      print("Google Sign-In init failed: $e");
    }
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    await _initialize();
    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);
      authController.clearError();

      // Start authentication flow
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // Fetch tokens from the account
      final tokens = account.authentication; // sync in v7
      print("tokens: $tokens");
      final idToken = tokens.idToken;
      print("*******");

      final verified = await authController.signInWithGoogleFirebase(idToken!);

      print("****************************************");
      print(verified);
      // ✅ Fetch user data
      final success = await authController.getUserData();
      print("****************************************");
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (!verified) {
        final error = ref.read(authControllerProvider).error;
        if (error != null && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
        return;
      }

      final userData = ref.read(authControllerProvider).userData;
      final token = ref.read(authControllerProvider).authToken;

      debugPrint("✅ Google Login response received");
      debugPrint("userData: $userData");
      debugPrint("token: $token");

      if (userData == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User data not found")));
        return;
      }

      final userDetails = userData['data'] ?? userData;
      final accType = userDetails['acc_type'] ?? 'guest';
      final profileFill = userDetails['profile_fill'] ?? 0;
      final userId = userDetails['id'].toString();

      debugPrint("userId: $userId, accType: $accType");

      // Save token and user details locally
      if (token != null) {
        await LaunchStatusService.saveAuthToken(token);
        await LaunchStatusService.saveUserData(userDetails);
      }

      await LaunchStatusService.setUserRole(accType);
      await LaunchStatusService.setUserId(userId);
      await ref.read(userProvider.notifier).loadUser();
      if (!mounted) return;

      // ✅ Navigation Logic
      if (profileFill == 1) {
        switch (accType) {
          case 'teacher':
            context.go('/teacher-dashboard');
            break;
          case 'student':
            context.go('/student-dashboard');
            break;
          case 'guest':
            context.go('/guest-dashboard', extra: {'guestId': userId});
            break;
          default:
            context.go('/error');
        }
      } else {
        context.go('/signup-stepper');
      }
    } catch (e) {
      debugPrint("Google Login Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: 600,
            width: double.infinity,
            child: Image.network(AppConfig.headerTop, fit: BoxFit.fitWidth),
          ),
          // Main Content with Rounded Container
          Column(
            children: [
              const SizedBox(height: 60),
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40, height: 40),
                    const Column(
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Let\'s get you started',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      margin: const EdgeInsets.only(right: 14.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.question_mark_sharp,
                          color: Colors.black,
                        ),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        onPressed: () => _showTopPopup(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Scrollable Body with Rounded Top Corners
              Expanded(
                child:
                    // Container(
                    //   width: double.infinity,
                    //   decoration: const BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(18),
                    //       topRight: Radius.circular(18),
                    //     ),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black12,
                    //         blurRadius: 10,
                    //         offset: Offset(0, -2),
                    //       ),
                    //     ],
                    //   ),
                    //   child:

                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 190,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 350,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Welcome to',
                                              style: TextStyle(
                                                color: Colors.black45,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  'Book',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                    fontFamily: 'PetrovSans',
                                                  ),
                                                ),
                                                Text(
                                                  'My',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'PetrovSans',
                                                    fontSize: 25,
                                                  ),
                                                ),
                                                Text(
                                                  'Teacher',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'PetrovSans',
                                                    fontSize: 25,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 180,
                                              height: 3,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.orangeAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 65),
                                      Center(
                                        child: SizedBox(
                                          width: 400.0,
                                          height: 50.0,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _handleGoogleLogin(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  'assets/images/icons/icon-google.png',
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                  height: 30,
                                                ),
                                                const Text(
                                                  "    Sign in with Google",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    letterSpacing: 1.1,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 30.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              thickness: 0.7,
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Text(
                                              'Or',
                                              style: TextStyle(
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              thickness: 0.7,
                                              color: Colors.grey.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30.0),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .white, // Background color of the container
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ), // Optional: rounded corners
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors
                                                    .black12, // Shadow color
                                                spreadRadius:
                                                    0.5, // Extent of the shadow spread
                                                blurRadius:
                                                    0.5, // Blurriness of the shadow
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ), // Offset of the shadow (x, y)
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              // Country code dropdown
                                              Container(
                                                height: 48,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                decoration: const BoxDecoration(
                                                  // border: Border(
                                                  //   top: const BorderSide(
                                                  //     color: Colors.grey,
                                                  //     width: 0,
                                                  //   ),
                                                  //   left: const BorderSide(
                                                  //     color: Colors.grey,
                                                  //     width: 0,
                                                  //   ),
                                                  //   right: const BorderSide(
                                                  //     color: Colors.orangeAccent,
                                                  //     width: 1,
                                                  //   ),
                                                  //   bottom: const BorderSide(
                                                  //     color: Colors.grey,
                                                  //     width: 0,
                                                  //   ),
                                                  // ),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              20.0,
                                                            ),
                                                        bottomLeft:
                                                            Radius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: _selectedCode,
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value: "+91",
                                                        child: Text(
                                                          " 🇮🇳 +91",
                                                        ),
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        setState(
                                                          () => _selectedCode =
                                                              value,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                              // Phone number input
                                              Expanded(
                                                child: SizedBox(
                                                  height: 55,
                                                  child: TextField(
                                                    controller:
                                                        _phoneController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        10,
                                                      ),
                                                    ],
                                                    decoration: const InputDecoration(
                                                      hintText:
                                                          "Enter Mobile Number",
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 7,
                                                          ),
                                                      // border: ,
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topRight:
                                                                  Radius.circular(
                                                                    20.0,
                                                                  ),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                    20.0,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Row(
                                      //   children: [
                                      // Checkbox(
                                      //   value: _isChecked,
                                      //   onChanged: (bool? newValue) {
                                      //     setState(() {
                                      //       _isChecked = newValue ?? false;
                                      //     });
                                      //   },
                                      // ),
                                      // Expanded(
                                      //   child: Row(
                                      //     children: [
                                      //       Text('I agree to ',
                                      //         style: TextStyle(
                                      //           color: Colors.green,
                                      //         ),
                                      //       ),
                                      //       GestureDetector(
                                      //         onTap: _launchTerms,
                                      //         child: const Text.rich(
                                      //           TextSpan(
                                      //             children: [
                                      //               TextSpan(
                                      //                 text:
                                      //                     'Terms and Conditions',
                                      //                 style: TextStyle(
                                      //                   color: Colors.black,
                                      //                   fontWeight:
                                      //                       FontWeight.bold,
                                      //                   decoration:
                                      //                       TextDecoration.none,
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // ],
                                      // ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: SizedBox(
                                          width: 150.0,
                                          height: 40.0,
                                          child: ElevatedButton(
                                            onPressed: _isLoading
                                                ? null
                                                : _sendOtp, // 🔒 Disabled when loading
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              disabledBackgroundColor:
                                                  Colors.grey,
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text("Send OTP"),
                                                      Icon(
                                                        Icons.play_arrow_sharp,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      thickness: 0.7,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'Sign up with single click',
                                      style: TextStyle(
                                        color: Colors.yellow[700],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 0.7,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),

                              ///////
                              const SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.go('/signup-otp-screen');
                                      // context.go('/signup-stepper');
                                    },
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                //   ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
