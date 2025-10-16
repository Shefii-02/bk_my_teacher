import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/app_config.dart';
import '../controller/auth_controller.dart';

class SignUpOtpScreen extends ConsumerStatefulWidget {
  const SignUpOtpScreen({super.key});

  @override
  ConsumerState<SignUpOtpScreen> createState() => _SignUpOtpScreenState();
}

class _SignUpOtpScreenState extends ConsumerState<SignUpOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isChecked = false;
  String _selectedCode = "+91";
  bool _isLoading = false;

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
                        "Sign up Instruction",
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
                    // "You can add any content here.",
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

  // Update your SignUpOtpScreen's send OTP method:
  Future<void> _sendOtp() async {
    if (_isLoading) return; // 🔒 Prevent multiple clicks
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms and Conditions"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

    final success = await authController.signupSendOtp(fullPhoneNumber);

    try {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP Sent Successfully..."),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to verification screen with phone number
        context.go(
          '/signup-verification-screen',
          extra: {'phoneNumber': fullPhoneNumber},
        );
      } else {
        // Error is already set in the state, we can show it
        final error = ref.read(authControllerProvider).error;
        if (error != null) {
          print(error);
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
                    const Column(
                      children: [
                        Text(
                          'SignUp',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Future start's now",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
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
                // child: Container(
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 290,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(height: 40),
                          SizedBox(
                            width: 350,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Book',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                          const Text(
                                            'My',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                          const Text(
                                            'Teacher',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 180,
                                        height: 3,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.yellow[700],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'The Future Starts Here...',
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40.0),
                                  Row(
                                    children: [
                                      const Text(
                                        "Mobile Number",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      // Country code dropdown
                                      Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                            left: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                            right: BorderSide.none,
                                            bottom: const BorderSide(
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
                                                child: Text("🇮🇳 +91"),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () => _selectedCode = value,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      // Phone number input
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: TextField(
                                            controller: _phoneController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                10,
                                              ),
                                            ],
                                            decoration: const InputDecoration(
                                              hintText: "Enter Mobile Number",
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(
                                                    20.0,
                                                  ),
                                                  bottomRight: Radius.circular(
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
                                        child: Row(
                                          children: [
                                            Text(
                                              'I agree to ',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                            GestureDetector(
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
                                                      text:
                                                          'Terms and Conditions',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration.none,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child:
                                        // SizedBox(
                                        //   width: 150.0,
                                        //   height: 40.0,
                                        //   child: ElevatedButton(
                                        //     onPressed: _isLoading
                                        //         ? null
                                        //         : _sendOtp,
                                        //     style: ElevatedButton.styleFrom(
                                        //       backgroundColor: Colors.green,
                                        //       foregroundColor: Colors.white,
                                        //       disabledBackgroundColor:
                                        //           Colors.grey,
                                        //     ),
                                        //     child: _isLoading
                                        //         ? const SizedBox(
                                        //             width: 20,
                                        //             height: 20,
                                        //             child:
                                        //                 CircularProgressIndicator(
                                        //                   color: Colors.white,
                                        //                   strokeWidth: 2,
                                        //                 ),
                                        //           )
                                        //         : const Row(
                                        //             mainAxisAlignment:
                                        //                 MainAxisAlignment.center,
                                        //             children: [
                                        //               Text("Send OTP"),
                                        //               Icon(
                                        //                 Icons.play_arrow_sharp,
                                        //               ),
                                        //             ],
                                        //           ),
                                        //   ),
                                        // ),
                                        SizedBox(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // ),
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
