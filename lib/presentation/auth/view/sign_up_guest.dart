import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:file_picker/file_picker.dart';
import '../../../core/enums/app_config.dart';
import '../../../services/launch_status_service.dart';
import '../controller/auth_controller.dart';
import '../providers/guest_signup_provider.dart';
import '../providers/student_provider.dart';

class SignUpGuest extends StatefulWidget {
  const SignUpGuest({super.key});

  @override
  State<SignUpGuest> createState() => _SignUpGuestState();
}

class _SignUpGuestState extends State<SignUpGuest> {
  int activeStep = 0;
  bool _isLoading = false;

  // ====== STEP 1: Personal Info ======
  final _fStep1 = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // File? _avatarFile;
  PlatformFile? _avatarFile;
  Uint8List? _avatarBytes; // For web
  String? _avatarName; // Store filename for web

  // ---------- Validators ----------
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[\w\.\-+]+@[\w\.\-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  String? _phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (v.length < 10) return 'Enter valid phone';
    return null;
  }

  // Future<void> _pickAvatar() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result != null) {
  //     setState(() {
  //       _avatarFile = result.files.first;
  //     });
  //   }
  // }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final file = result.files.first;
      if (file.size > 2 * 1024 * 1024) {
        // 2 MB limit
        _toast("Profile Pic size must be less than 2 MB");
        return;
      }
      setState(() {
        _avatarFile = result.files.first;
        _avatarBytes = result.files.first.bytes;
        _avatarName = result.files.first.name;
      });
    }
  }

  // ---------- Step validators ----------
  // bool _validateStep1() => _fStep1.currentState?.validate() ?? false;
  bool _validateStep1() {
    final ok = _fStep1.currentState?.validate() ?? false;
    if (!ok) return false;

    if (_avatarFile != null || _avatarBytes != null) {
      if (_avatarFile != null && _avatarFile!.size > 2 * 1024 * 1024) {
        _toast("Avatar size must be less than 2 MB");
        return false;
      }
      return true;
    } else {
      _toast('Please select an profile image');
      return false;
    }
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---------- Submit ----------
  Future<void> _submitForm() async {
    if (_isLoading) return;

    setState(() => _isLoading = true); // ⏳ Start loader immediately

    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final avatar = _avatarFile;

    // Debug prints
    // print("➡️ fullName: $fullName");
    // print("➡️ email: $email");
    // print("➡️ avatar: ${avatar?.name ?? 'No avatar selected'}");

    final formData = {"full_name": fullName, "email": email, "avatar": avatar};

    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final response = await container.read(
        guestSignupProvider(formData).future,
      );

      final userRole = response['user']?['acc_type'] ?? 'guest';

      final authController = container.read(authControllerProvider);
      final userId = response['user']['id'];

      final userData = response['user'];
      // final token = response['token'];

      if (userData != null) {
        // ✅ Save auth token + user data locally
        // await LaunchStatusService.saveAuthToken(token);
        await LaunchStatusService.saveUserData(userData);

        // ✅ Set token for all future API calls
        // container.read(guestApiProvider).setAuthToken(token);
      }

      await LaunchStatusService.setUserRole(userRole);
      // await LaunchStatusService.setUserId(userId.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Registration Successful"),
        ),
      );

      setState(() => _isLoading = true);

      context.go('/guest-dashboard', extra: {'guestId': userId.toString()});
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- UI ----------
  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    // _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Container(
            height: 600,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(AppConfig.headerTop),
                fit: BoxFit.fill,
              ),
            ),
          ),
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
                        onPressed: () => context.go('/signup-stepper'),
                      ),
                    ),
                    // Title
                    const Column(
                      children: [
                        Text(
                          'I\'m a Guest',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please fill your details',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    // Help
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
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
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
                    child: Column(
                      children: [
                        // Stepper
                        // Container(
                        //   margin: const EdgeInsets.symmetric(
                        //     vertical: 10.0,
                        //     horizontal: 10.0,
                        //   ),
                        //   child: EasyStepper(
                        //     steppingEnabled: false,
                        //     internalPadding: 60,
                        //     activeStep: activeStep,
                        //     fitWidth: true,
                        //     stepShape: StepShape.circle,
                        //     stepBorderRadius: 10,
                        //     borderThickness: 2,
                        //     stepRadius: 10,
                        //     lineStyle: const LineStyle(
                        //       lineSpace: 4,
                        //       lineType: LineType.normal,
                        //     ),
                        //     finishedStepBorderColor: Colors.green,
                        //     finishedStepTextColor: Colors.green,
                        //     finishedStepBackgroundColor: Colors.green,
                        //     activeStepBorderColor: Colors.green,
                        //     activeStepBackgroundColor: Colors.green,
                        //     unreachedStepBorderColor: Colors.grey,
                        //     unreachedStepBackgroundColor: Colors.grey,
                        //     showLoadingAnimation: true,
                        //     showStepBorder: true,
                        //     steps: const [
                        //       EasyStep(
                        //         customTitle: Padding(
                        //           padding: EdgeInsets.only(top: 8.0),
                        //           child: Center(
                        //             child: Text('Personal Details'),
                        //           ),
                        //         ),
                        //         customStep: CircleAvatar(
                        //           radius: 5,
                        //           backgroundColor: Colors.white,
                        //           child: CircleAvatar(radius: 3),
                        //         ),
                        //       ),
                        //     ],
                        //     onStepReached: (index) =>
                        //         setState(() => activeStep = index),
                        //   ),
                        // ),

                        // Step content
                        _buildStepContent(),

                        const SizedBox(height: 20),

                        // Nav buttons
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 40.0,
                            bottom: 30,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (activeStep > 0)
                                OutlinedButton(
                                  onPressed: () => setState(() => activeStep--),
                                  child: const Text('Back'),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (_validateStep1()) {
                                          _submitForm();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Submit',
                                  style: const TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildStepContent() {
    return _step1Personal();
  }

  // -------- STEP 1 UI --------
  Widget _step1Personal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _fStep1,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _avatarFile != null
                      ? (kIsWeb
                            ? MemoryImage(_avatarFile!.bytes!) // ✅ Web
                            : FileImage(
                                    File(_avatarFile!.path!),
                                  ) // ✅ Mobile/Desktop
                                  as ImageProvider)
                      : null,
                  child: _avatarFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white70,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _tf(_fullNameCtrl, 'Full Name', validator: _req),
            const SizedBox(height: 30),
            _tf(
              _emailCtrl,
              'Email Id',
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
            const SizedBox(height: 20),
            // _tf(
            //   _phoneCtrl,
            //   'Phone',
            //   keyboardType: TextInputType.phone,
            //   validator: _phone,
            // ),
          ],
        ),
      ),
    );
  }

  // -------- Shared TextField --------
  Widget _tf(
    TextEditingController c,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }
}
