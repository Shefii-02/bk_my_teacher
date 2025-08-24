import 'package:app/presentation/auth/view/signup_stepper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../controller/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController phoneController = TextEditingController();
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  bool otpSent = false;
  bool _isChecked = false;
  String _selectedCode = "+91";
  final TextEditingController _phoneController = TextEditingController();
  void _showTopPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 60, left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
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
                      Text(
                        "Login or Sign In Instruction",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Divider(),
                  Text(
                    "This is your offcanvas-top style popup with animation. "
                    "You can add any content here.",
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
            begin: Offset(0, -1), // start from top
            end: Offset(0, 0),
          ).animate(anim),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.asset(
              'assets/images/background/full-bg.jpg',
              fit: BoxFit.fill,
              // width: double.infinity,
              // height: double.infinity,
            ),
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
                    // Back button
                    SizedBox(
                      width: 40,
                      height: 40,
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   color: Colors.white.withOpacity(0.8),
                      // ),
                      child: Text(''),
                      // IconButton(
                      //   icon: const Icon(Icons.arrow_back, color: Colors.black),
                      //   iconSize: 20,
                      //   padding: EdgeInsets.zero,
                      //   onPressed: () => {
                      //     if (context.canPop())
                      //       {context.pop()}
                      //     else
                      //       {
                      //         SystemNavigator.pop(),
                      //       },
                      //   },
                      //   // Navigator.pop(context),
                      // ),
                    ),

                    // Title
                    Column(
                      children: const [
                        Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Let’s get you started',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    // Help button
                    Container(
                      width: 35,
                      height: 35,
                      margin: EdgeInsets.only(right: 14.0),
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   border: Border.all(color: Colors.grey, width: 0.8),
                      //   color: Colors.transparent,
                      // ),
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
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            290, // minus appbar height
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // vertical centering
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Book',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'My',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Teacher',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Text(
                                  //   'BookMyTeacher',
                                  //   style: TextStyle(
                                  //     color: Colors.black,
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize: 30,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            const Text(
                              "Mobile Number",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                // Country code dropdown
                                Container(
                                  height: 48, // same height as TextField
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: Colors.grey),
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      right: BorderSide.none,
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      bottomLeft: Radius.circular(20.0),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCode,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "+91",
                                          child: Text("🇮🇳 +91"),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _selectedCode = value);
                                        }
                                      },
                                    ),
                                  ),
                                ),

                                // Phone number input
                                Expanded(
                                  child: SizedBox(
                                    height: 48, // match height
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "Enter Mobile Number",
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(20.0),
                                            bottomRight: Radius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isChecked,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _isChecked = newValue ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _launchTerms,
                                    child: const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'I agree to ',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Terms and Conditions',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: 150.0, // Specific button width
                                height: 40.0, // Specific button height
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      // if (!otpSent) {
                                      final msg = await authController.sendOtp(
                                        mobileController.text,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                      context.go('/verification-screen');

                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                      context.go('/verification-screen');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 40),
                                    backgroundColor: Colors
                                        .green, // Background color of the button
                                    foregroundColor: Colors
                                        .white, // Text/icon color on the button
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // vertical centering
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Send OTP"),
                                      Icon(Icons.play_arrow_sharp),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Sign in with single click',
                                    style: TextStyle(color: Colors.black45),
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
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: 400.0, // Specific button width
                                height: 60.0, // Specific button height
                                child: ElevatedButton(
                                  onPressed: () {
                                    // ref.refresh(googleSignInProvider);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 35),
                                    backgroundColor: Colors
                                        .green[50], // Background color of the button
                                    foregroundColor: Colors
                                        .white, // Text/icon color on the button
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // vertical centering
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/icons/icon-google.png',
                                      ),
                                      const SizedBox(width: 15, height: 30),
                                      const Text(
                                        "Sign in using your Google",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpStepper(),
                                      ),
                                    );
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchTerms() async {
    final Uri url = Uri.parse(
      'https://www.bookmyteachar.co.in/terms-and-conditions',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
