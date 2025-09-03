import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter/services.dart';
import '../controller/auth_controller.dart';

class SignUpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const SignUpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<SignUpVerificationScreen> createState() => _SignUpVerificationScreenState();
}

class _SignUpVerificationScreenState extends ConsumerState<SignUpVerificationScreen>
    with CodeAutoFill {
  String otpCode = "";
  bool _isLoading = false;
  Timer? _resendTimer;
  int _resendCooldown = 120; // 2 minutes in seconds
  int _resendAttempts = 0;

  @override
  void initState() {
    super.initState();
    listenForCode();
    _startResendTimer();
  }

  @override
  void dispose() {
    cancel(); // stop listening for OTP
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code ?? "";
    });

    if (otpCode.length == 4) {
      _verifyOtp();
    }
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpCode.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 4-digit OTP")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authController = ref.read(authControllerProvider.notifier);
    authController.clearError();

    final verified = await authController.verifyOtp(otpCode);

    setState(() {
      _isLoading = false;
    });

    if (verified) {
      // Navigate to home screen on successful verification
      await authController.getUserData();
      context.go('/signup-stepper');
    } else {
      // Show error from state
      final error = ref.read(authControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendAttempts >= 2 && _resendCooldown > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please wait ${_formatCooldownTime(_resendCooldown)} before resending"),
        ),
      );
      return;
    }

    if (_resendAttempts >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum resend attempts reached. Please wait 5 minutes.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authController = ref.read(authControllerProvider.notifier);
    authController.clearError();

    final success = await authController.resendOtp();

    setState(() {
      _isLoading = false;
      _resendAttempts++;

      if (_resendAttempts >= 2) {
        _resendCooldown = 120; // Reset to 2 minutes
        _startResendTimer();
      }

      if (_resendAttempts >= 3) {
        _resendCooldown = 300; // 5 minutes cooldown
        _startResendTimer();
      }
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent successfully")),
      );

      // Clear OTP field
      setState(() {
        otpCode = "";
      });
    } else {
      // Show error from state
      final error = ref.read(authControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  String _formatCooldownTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

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
                        "Mobile Number Verification Instruction",
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
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _resendCooldown == 0 && _resendAttempts < 3;

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
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).reset();
                          // context.pop();
                          context.go('/auth');
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
                                Text(
                                  widget.phoneNumber,
                                  style: const TextStyle(
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
                                      ref.read(authControllerProvider.notifier).reset();
                                      context.go('/signin');
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
                                  radius: const Radius.circular(15),
                                  strokeColorBuilder: FixedColorBuilder(Colors.grey[50]!),
                                  bgColorBuilder: FixedColorBuilder(Colors.grey.shade200),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                onCodeChanged: (code) {
                                  if (code != null) {
                                    setState(() {
                                      otpCode = code;
                                    });

                                    if (code.length == 4) {
                                      _verifyOtp();
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 30),

                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              SizedBox(
                                width: 150.0,
                                height: 40.0,
                                child: ElevatedButton(
                                  onPressed: _verifyOtp,
                                  style: ElevatedButton.styleFrom(
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

                            const SizedBox(height: 20),

                            // Resend OTP section
                            Column(
                              children: [
                                if (canResend)
                                  TextButton(
                                    onPressed: _resendOtp,
                                    child: const Text("Resend OTP"),
                                  )
                                else
                                  Text(
                                    "Resend available in ${_formatCooldownTime(_resendCooldown)}",
                                  ),

                                if (_resendAttempts >= 1)
                                  Text("${3 - _resendAttempts} attempts remaining"),
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
}

// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../controller/auth_controller.dart';
//
// class SignUpVerificationScreen extends ConsumerStatefulWidget {
//   final Map<String, dynamic> extra;
//
//   const SignUpVerificationScreen({super.key, required this.extra});
//
//   @override
//   ConsumerState<SignUpVerificationScreen> createState() => _SignUpVerificationScreenState();
// }
//
// class _SignUpVerificationScreenState extends ConsumerState<SignUpVerificationScreen> {
//   final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
//   String _phoneNumber = '';
//   int _resendCount = 0;
//   bool _canResend = true;
//   int _cooldownSeconds = 0;
//   Timer? _cooldownTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _phoneNumber = widget.extra['phoneNumber'] ?? '';
//     _resendCount = widget.extra['resendCount'] ?? 0;
//     _canResend = widget.extra['resendAllowed'] ?? true;
//
//     // Setup OTP field focus management
//     for (int i = 0; i < _focusNodes.length; i++) {
//       _focusNodes[i].addListener(() {
//         if (_focusNodes[i].hasFocus && _otpControllers[i].text.isEmpty && i > 0) {
//           _focusNodes[i-1].requestFocus();
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     _cooldownTimer?.cancel();
//     super.dispose();
//   }
//
//   void _verifyOtp() async {
//     final otp = _otpControllers.map((controller) => controller.text).join();
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
//       );
//       return;
//     }
//
//     final authController = ref.read(authControllerProvider.notifier);
//     final verified = await authController.verifyOtp(_phoneNumber, otp);
//
//     if (verified) {
//       context.go('/home');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid OTP. Please try again.")),
//       );
//     }
//   }
//
//   void _resendOtp() async {
//     if (!_canResend) return;
//
//     final authController = ref.read(authControllerProvider.notifier);
//     final success = await authController.resendOtp(_phoneNumber);
//
//     if (success) {
//       setState(() {
//         _resendCount++;
//         if (_resendCount >= 3) {
//           _canResend = false;
//           _cooldownSeconds = 300;
//           _startCooldownTimer();
//         }
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("OTP sent successfully")),
//       );
//
//       // Clear OTP fields
//       for (var controller in _otpControllers) {
//         controller.clear();
//       }
//       _focusNodes[0].requestFocus();
//     }
//   }
//
//   void _startCooldownTimer() {
//     _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_cooldownSeconds > 0) {
//         setState(() {
//           _cooldownSeconds--;
//         });
//       } else {
//         setState(() {
//           _canResend = true;
//         });
//         timer.cancel();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Verify OTP"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text("Enter OTP sent to $_phoneNumber"),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(6, (index) {
//                 return SizedBox(
//                   width: 40,
//                   child: TextField(
//                     controller: _otpControllers[index],
//                     focusNode: _focusNodes[index],
//                     textAlign: TextAlign.center,
//                     keyboardType: TextInputType.number,
//                     maxLength: 1,
//                     decoration: const InputDecoration(counterText: ""),
//                     onChanged: (value) {
//                       if (value.isNotEmpty && index < 5) {
//                         _focusNodes[index+1].requestFocus();
//                       }
//                       if (value.isEmpty && index > 0) {
//                         _focusNodes[index-1].requestFocus();
//                       }
//                       if (value.isNotEmpty && index == 5) {
//                         _verifyOtp();
//                       }
//                     },
//                   ),
//                 );
//               }),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _verifyOtp,
//               child: const Text("Verify OTP"),
//             ),
//             const SizedBox(height: 20),
//             if (_canResend)
//               TextButton(
//                 onPressed: _resendOtp,
//                 child: const Text("Resend OTP"),
//               )
//             else
//               Text("Resend available in $_cooldownSeconds seconds"),
//             if (_resendCount >= 2)
//               Text("${3 - _resendCount} attempts remaining"),
//           ],
//         ),
//       ),
//     );
//   }
// }
