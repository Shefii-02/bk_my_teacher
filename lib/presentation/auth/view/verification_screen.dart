import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../routes/app_router.dart';
import '../../../services/launch_status_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with CodeAutoFill {
  final TextEditingController phoneController = TextEditingController();
  String otpCode = "";

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel(); // stop listening for OTP
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code ?? "";
    });

    if (otpCode.length == 4) {
      _handleLogin();
    }
  }

  Future<void> _handleLogin() async {
    final phone = phoneController.text.trim();

    if (phone == "1234567890") {
      await LaunchStatusService.setUserRole('student');
      if (mounted) context.go(AppRoutes.verificationScreen);
    } else {
      await LaunchStatusService.setUserRole('teacher');
      if (mounted) context.go(AppRoutes.verificationScreen);
    }
  }

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
                        "Mobile Number Verification Instruction",
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image for AppBar section
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        onPressed: () => {
                          // if (context.canPop())
                          //   {context.pop()}
                          // else
                          //   {SystemNavigator.pop()},
                          context.go('/auth'),
                        },
                      ),
                    ),

                    // Title
                    Column(
                      children: const [
                        Text(
                          'Verification',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Verify your mobile number',
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 0.8),
                        color: Colors.transparent,
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
                        minHeight: MediaQuery.of(context).size.height - 290,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 13),
                            Image.asset(
                              'assets/images/icons/OTP_Code.png',
                              height: 200,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Verification code",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 350,
                              child: const Text(
                                'We have sent OTP code verification to your mobile no',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '+91 7565 005 530',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.red,
                                  ),
                                  width: 30,
                                  height: 30,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20.0,
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      context.go('/auth');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            // OTP Auto Fill
                            SizedBox(
                              height: 65.0,
                              width: 320,
                              child: PinFieldAutoFill(
                                currentCode: otpCode,
                                codeLength: 4,
                                decoration: BoxLooseDecoration(
                                  radius: const Radius.circular(
                                    23,
                                  ), // Rounded corners
                                  strokeColorBuilder: FixedColorBuilder(
                                    Colors.grey,
                                  ),
                                  bgColorBuilder: FixedColorBuilder(
                                    Colors.grey.shade200,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                onCodeChanged: (code) {
                                  if (code != null && code.length == 4) {
                                    otpCode = code;
                                    // _handleLogin();
                                    final msg = await authController.verifyOtp(
                                      mobileController.text,
                                      otpController.text,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 150.0,
                              height: 40.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.go('/signup-teacher');
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 40),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  "Validate",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
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
}
