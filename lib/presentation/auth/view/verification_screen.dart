import 'dart:async';

import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../services/launch_status_service.dart';
import '../controller/auth_controller.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen>
    with CodeAutoFill {
  String otpCode = "";
  bool _isLoading = false;
  Timer? _resendTimer;
  int _resendCooldown = 120; // 2 minutes
  int _resendAttempts = 0;

  @override
  void initState() {
    super.initState();
    listenForCode();
    _startResendTimer();
  }

  @override
  void dispose() {
    cancel(); // stop listening OTP
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() => otpCode = code ?? "");
    if (otpCode.length == 4) _verifyOtp();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (otpCode.length != 4) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 4-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authController = ref.read(authControllerProvider.notifier);
    authController.clearError();

    final verified = await authController.verifyOtp(otpCode);
    print("****************************");
    print("Verification Status");
    print(verified);
    print("****************************");

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

    // ✅ Fetch user data
    final success = await authController.getUserData();

    print("****************************");
    print("getUserData Result");
    print(success);
    print("****************************");

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch user data")),
      );
      return;
    }



    final userData = ref.read(authControllerProvider).userData;
    final token = ref.read(authControllerProvider).authToken;

    print("****************************");
    print("userData Result");
    print(userData);
    print("****************************");

    print("****************************");
    print("token Result");
    print(token);
    print("****************************");

    if (userData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User data not found")));
      return;
    }


    final userDetails = userData['data'] ?? userData;
    print("****************************");
    print("userDetails");
    print(userDetails);
    print("****************************");
    if (token != null) {
      print("........");
      await LaunchStatusService.saveAuthToken(token);
      await LaunchStatusService.saveUserData(userDetails);
    }

    final accType = userDetails['acc_type'] ?? 'guest';
    final profileFill = userDetails['profile_fill'] ?? 0;
    final userId = userDetails['id'].toString() ?? '';

    print("****************************");
    print("userId");
    print(userId);
    print("****************************");

    await LaunchStatusService.setUserRole(accType);
    await LaunchStatusService.setUserId(userId);

    print("****************************");
    print("accType");
    print(accType);
    print("****************************");

    // ✅ Navigate based on account type
    if (!mounted) return;
    if (profileFill == 1) {
      if (accType == 'teacher') {
        context.go(
          '/teacher-dashboard',
          extra: {'teacherId': userId.toString()},
        );
      } else if (accType == 'student') {
        context.go(
          '/student-dashboard',
          extra: {'studentId': userId.toString()},
        );
        // context.go('/student-dashboard');
      } else if (accType == 'guest') {
        context.go(
          '/guest-dashboard',
          extra: {'guestId': userId.toString()},
        );
        // context.go('/guest-dashboard');
      } else {
        context.go('/error');
      }
    } else {
      context.go('/signup-stepper');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendAttempts >= 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Maximum resend attempts reached. Please wait 5 minutes.",
          ),
        ),
      );
      return;
    }

    if (_resendAttempts >= 2 && _resendCooldown > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please wait ${_formatCooldownTime(_resendCooldown)} before resending",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authController = ref.read(authControllerProvider.notifier);
    authController.clearError();

    final success = await authController.resendOtp();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _resendAttempts++;
      if (_resendAttempts >= 2) _resendCooldown = 120;
      if (_resendAttempts >= 3) _resendCooldown = 300;
      _startResendTimer();
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP sent successfully")));
      setState(() => otpCode = "");
    } else {
      final error = ref.read(authControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  String _formatCooldownTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$sec';
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
                  const Text("", style: TextStyle(fontSize: 14)),
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
            end: Offset.zero,
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
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(AppConfig.headerTop, fit: BoxFit.fill),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          context.go('/auth');
                        },
                      ),
                    ),
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
                                      ref
                                          .read(authControllerProvider.notifier)
                                          .reset();
                                      context.go('/signin');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              height: 65,
                              width: 320,
                              child: PinFieldAutoFill(
                                currentCode: otpCode,
                                codeLength: 4,
                                decoration: BoxLooseDecoration(
                                  radius: const Radius.circular(15),
                                  strokeColorBuilder: FixedColorBuilder(
                                    Colors.grey[50]!,
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
                                  if (code != null) {
                                    setState(() => otpCode = code);
                                    if (code.length == 4) _verifyOtp();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              SizedBox(
                                width: 150,
                                height: 40,
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
// class VerificationScreen extends ConsumerStatefulWidget {
//   final Map<String, dynamic> extra;
//
//   const VerificationScreen({super.key, required this.extra});
//
//   @override
//   ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
// }
//
// class _VerificationScreenState extends ConsumerState<VerificationScreen> {
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
