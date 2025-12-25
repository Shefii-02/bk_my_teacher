import 'dart:io';
import 'package:BookMyTeacher/presentation/auth/view/referral_popup.dart';
import 'package:BookMyTeacher/services/api_service.dart';
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
import '../providers/student_provider.dart';

class SignUpStudent extends StatefulWidget {
  const SignUpStudent({super.key});

  @override
  State<SignUpStudent> createState() => _SignUpStudentState();
}

class _SignUpStudentState extends State<SignUpStudent> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final ScrollController _scrollController = ScrollController();

  int activeStep = 0;
  bool _isLoading = false;

  // ====== STEP 1: Personal Info ======
  final _fStep1 = GlobalKey<FormState>();
  final _studentNameCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  // ====== STEP 2: Study Details ======
  final _fStep2 = GlobalKey<FormState>();
  String _interest = "offline"; // offline | online | both

  // File? _avatarFile;
  PlatformFile? _avatarFile;
  Uint8List? _avatarBytes; // For web
  String? _avatarName; // Store filename for web

  List<Map<String, dynamic>> listingGrades = [];
  List<Map<String, dynamic>> listingSubjects = [];

  Future<void> _loadData() async {
    final api = ApiService();
    try {
      final grades = await api.getListingGrades();
      final subjects = await api.getListingSubjects();

      setState(() {
        listingGrades = grades;
        listingSubjects = subjects;
        listingSubjects = [
          ...subjects,
          {
            "id": "other",
            "name": "Other",
            "value": 'other',
          }, // 👈 always append
        ];
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  void _goNextStep() {
    setState(() {
      activeStep = 1;
    });

    // ✅ Scroll to top smoothly
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // Teaching Grades (chips)
  bool _lowerPrimary = false;
  bool _upto10 = false;
  bool _higherSecondary = false;
  bool _graduate = false;
  bool _postGraduate = false;

  // Teaching Subjects (chips)
  bool _allSubjects = false;
  bool _maths = false;
  bool _science = false;
  bool _malayalam = false;
  bool _english = false;
  bool _other = false;
  final _otherSubjectCtrl = TextEditingController();

  final List<String> _selectedGrades = [];
  final List<String> _selectedSubjects = [];

  // Preferable Days & Hours (chips)
  final List<String> _days = const [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];
  final List<String> _selectedDays = [];
  final List<String> _hours = const [
    "06.00-07.00 AM",
    "07.00-08.00 AM",
    "08.00-09.00 AM",
    "09.00-10.00 AM",
    "10.00-11.00 AM",
    "11.00-12.00 PM",
    "12.00-01.00 PM",
    "01.00-02.00 PM",
    "02.00-03.00 PM",
    "03.00-04.00 PM",
    "04.00-05.00 PM",
    "05.00-06.00 PM",
    "06.00-07.00 PM",
    "07.00-08.00 PM",
    "08.00-09.00 PM",
    "09.00-10.00 PM",
    "10.00-11.00 PM",
  ];
  final List<String> _selectedHours = [];

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
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'jpeg', 'png'],
  //   );
  //
  //   if (result != null) {
  //     if (kIsWeb) {
  //       // On Web
  //       setState(() {
  //         _avatarFile = null;
  //         _avatarBytes = result.files.single.bytes;
  //         _avatarName = result.files.single.name;
  //       });
  //     } else {
  //       // On Mobile/Desktop
  //       setState(() {
  //         _avatarFile = File(result.files.single.path!);
  //       });
  //     }
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('No image selected')));
  //   }
  // }

  // Future<void> _pickAvatar() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result != null) {
  //     final file = result.files.first;
  //     if (file.size > 2 * 1024 * 1024) { // 2 MB limit
  //       _toast("Profile Pic size must be less than 2 MB");
  //       return;
  //     }
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

  bool _validateStep2() => _fStep2.currentState?.validate() ?? false;

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---------- Submit ----------
  Future<void> _submitForm() async {
    if (_isLoading) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];
    final userId = await LaunchStatusService.getUserId();

    final formData = {
      "student_id": userId,
      "student_name": _studentNameCtrl.text.trim(),
      "parent_name": _parentNameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      // "phone": _phoneCtrl.text.trim(),
      "address": _addressCtrl.text.trim(),
      "city": _cityCtrl.text.trim(),
      "postalCode": _postalCtrl.text.trim(),
      "district": _districtCtrl.text.trim(),
      "state": _stateCtrl.text.trim(),
      "country": _countryCtrl.text.trim(),
      "avatar": _avatarFile,
      "interest": _interest,
      "selectedDays": _selectedDays,
      "selectedHours": _selectedHours,
      "seekingGrades": _selectedGrades, // ✅ dynamic
      // "seekingSubjects": _selectedSubjects, // ✅ dynamic
      "seekingSubjects": [
        ..._selectedSubjects,
        if (_other && _otherSubjectCtrl.text.trim().isNotEmpty)
          _otherSubjectCtrl.text.trim(),
      ],
      // "seekingGrades": [
      //   if (_lowerPrimary) "lowerPrimary",
      //   if (_upto10) "upto10",
      //   if (_higherSecondary) "higherSecondary",
      //   if (_graduate) "graduate",
      //   if (_postGraduate) "postGraduate",
      // ],
      // "seekingSubjects": [
      //   if (_allSubjects) "all",
      //   if (_maths) "maths",
      //   if (_science) "science",
      //   if (_malayalam) "malayalam",
      //   if (_english) "english",
      //   if (_other) _otherSubjectCtrl.text.trim(),
      // ],
    };

    try {
      final response = await container.read(
        studentSignupProvider(formData).future,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Registration Successful"),
        ),
      );

      final userRole = response['user']?['acc_type'] ?? 'student';
      // final userId = response['user']['id'];

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
      // await LaunchStatusService.setUserId(userId!.toString());

      setState(() => _isLoading = true); // ⏳ Show loader
      _showReferralPopup(context);
      // context.go('/student-dashboard');
      // context.go('/student-dashboard', extra: {'studentId': userId});
      // }
      // catch (e) {
      //   print(e);
      //   _toast("❌ Error: $e");
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false); // ✅ Hide loader
    }
  }

  // ---------- UI ----------
  @override
  void dispose() {
    _studentNameCtrl.dispose();
    _parentNameCtrl.dispose();
    _emailCtrl.dispose();
    // _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _otherSubjectCtrl.dispose();

    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Stack(
  //       children: [
  //         // Background Image
  //         Container(
  //           height: 200,
  //           width: double.infinity,
  //           decoration: const BoxDecoration(
  //             image: DecorationImage(
  //               image: NetworkImage(AppConfig.headerTop),
  //               fit: BoxFit.fill,
  //             ),
  //           ),
  //         ),
  //         Column(
  //           children: [
  //             const SizedBox(height: 60),
  //             // Custom AppBar
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   // Back button
  //                   Container(
  //                     width: 40,
  //                     height: 40,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: Colors.white.withOpacity(0.8),
  //                     ),
  //                     child: IconButton(
  //                       icon: const Icon(Icons.arrow_back, color: Colors.black),
  //                       iconSize: 20,
  //                       padding: EdgeInsets.zero,
  //                       onPressed: () => context.go('/signup-stepper'),
  //                     ),
  //                   ),
  //                   // Title
  //                   const Column(
  //                     children: [
  //                       Text(
  //                         'I\'m a Student',
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 18.0,
  //                         ),
  //                       ),
  //                       SizedBox(height: 4),
  //                       Text(
  //                         'Please fill your details',
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 12.0,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   // Help
  //                   Container(
  //                     width: 35,
  //                     height: 35,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       border: Border.all(color: Colors.grey, width: 0.8),
  //                       color: Colors.transparent,
  //                     ),
  //                     child: IconButton(
  //                       icon: const Icon(
  //                         Icons.question_mark_sharp,
  //                         color: Colors.black,
  //                       ),
  //                       iconSize: 18,
  //                       padding: EdgeInsets.zero,
  //                       onPressed: () {},
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             const SizedBox(height: 20),
  //
  //             // Main body
  //             Expanded(
  //               child: Container(
  //                 width: double.infinity,
  //                 decoration: const BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(30),
  //                     topRight: Radius.circular(30),
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 10,
  //                       offset: Offset(0, -2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: SingleChildScrollView(
  //                   controller: _scrollController,
  //                   child: Column(
  //                     children: [
  //                       // Stepper
  //                       Container(
  //                         margin: const EdgeInsets.symmetric(
  //                           vertical: 10.0,
  //                           horizontal: 10.0,
  //                         ),
  //                         child: EasyStepper(
  //                           steppingEnabled: false,
  //                           internalPadding: 60,
  //                           activeStep: activeStep,
  //                           fitWidth: true,
  //                           stepShape: StepShape.circle,
  //                           stepBorderRadius: 10,
  //                           borderThickness: 2,
  //                           stepRadius: 10,
  //                           lineStyle: const LineStyle(
  //                             lineSpace: 4,
  //                             lineType: LineType.normal,
  //                           ),
  //                           finishedStepBorderColor: Colors.green,
  //                           finishedStepTextColor: Colors.green,
  //                           finishedStepBackgroundColor: Colors.green,
  //                           activeStepBorderColor: Colors.green,
  //                           activeStepBackgroundColor: Colors.green,
  //                           unreachedStepBorderColor: Colors.grey,
  //                           unreachedStepBackgroundColor: Colors.grey,
  //                           showLoadingAnimation: true,
  //                           showStepBorder: true,
  //                           steps: const [
  //                             EasyStep(
  //                               customTitle: Padding(
  //                                 padding: EdgeInsets.only(top: 8.0),
  //                                 child: Center(
  //                                   child: Text('Personal Details'),
  //                                 ),
  //                               ),
  //                               customStep: CircleAvatar(
  //                                 radius: 5,
  //                                 backgroundColor: Colors.white,
  //                                 child: CircleAvatar(radius: 3),
  //                               ),
  //                             ),
  //                             EasyStep(
  //                               customTitle: Padding(
  //                                 padding: EdgeInsets.only(top: 8.0),
  //                                 child: Center(child: Text('Study Details')),
  //                               ),
  //                               customStep: CircleAvatar(
  //                                 radius: 5,
  //                                 backgroundColor: Colors.white,
  //                                 child: CircleAvatar(radius: 3),
  //                               ),
  //                             ),
  //                           ],
  //                           onStepReached: (index) =>
  //                               setState(() => activeStep = index),
  //                         ),
  //                       ),
  //
  //                       // Step content
  //                       _buildStepContent(),
  //
  //                       const SizedBox(height: 20),
  //
  //                       // Nav buttons
  //                       Padding(
  //                         padding: const EdgeInsets.only(
  //                           right: 40.0,
  //                           bottom: 30,
  //                         ),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           children: [
  //                             if (activeStep > 0)
  //                               OutlinedButton(
  //                                 onPressed: () => setState(() => activeStep--),
  //                                 child: const Text('Back'),
  //                               ),
  //                             const SizedBox(width: 8),
  //                             ElevatedButton(
  //                               onPressed: _isLoading
  //                                   ? null
  //                                   : () {
  //                                       if (activeStep == 0) {
  //                                         if (_validateStep1()) {
  //                                           setState(() => activeStep = 1);
  //                                           _goNextStep(); // ✅ scrolls to top
  //                                         }
  //                                       } else {
  //                                         if (_validateStep2()) {
  //                                           _submitForm();
  //                                         }
  //                                       }
  //                                     },
  //                               child: _isLoading
  //                                   ? const SizedBox(
  //                                       width: 20,
  //                                       height: 20,
  //                                       child: CircularProgressIndicator(
  //                                         strokeWidth: 2,
  //                                         color: Colors.white,
  //                                       ),
  //                                     )
  //                                   : Text(activeStep == 1 ? 'Submit' : 'Next'),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Light green/teal background
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       // Color(0xFF6CC57D),
            //       Color(0xFF388E3C),
            //       // Color(0xFF2E7D32),
            //       // Color(0xFF1B5E20),
            //       // Color(0xFF6CCFBA),
            //       // Color(0xFF1D6FA3), // soft blue
            //       Color(0xFF48C6EF), // light blue-green
            //     ],
            //     // stops: [0.0, 0.3, 0.7,0.9],
            //   ),
            // ),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(15),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black.withOpacity(0.1),
            //       blurRadius: 10,
            //       offset: Offset(0, 5),
            //     ),
            //   ],
            //   gradient: LinearGradient( // THIS IS THE GRADIENT FOR THE ICON BACKGROUND
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       Color(0xFF6CC57D),
            //       Color(0xFF48C6EF),
            //       Color(0xFF48C6EF),
            //       Color(0xFF1B5E20),
            //     ],
            //     stops: [0.0, 0.3, 0.7, 1.0],
            //   ),
            // ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF114887), // A vibrant blue
                  Color(0xFF6DE899), // A soft green
                ],
                stops: [
                  0.0,
                  1.0,
                ], // Blue at the bottom-left (0%), Green at the top-right (100%)
              ),
            ),
          ),
          // Background "blur" effect if you want to mimic the image exactly
          // You might need a more complex setup for a true blur or use an asset image
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.0), // Start with transparent
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 30.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // _buildStepperIndicators(),
                          // const SizedBox(height: 30),
                          _buildStepContent(),
                          const SizedBox(height: 30),
                          _buildNavigationButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Buttons
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (activeStep > 0)
          OutlinedButton(
            onPressed: _isLoading ? null : () => setState(() => activeStep--),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Back', style: TextStyle(color: Colors.black87)),
          ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _isLoading ? null : _nextOrSubmit,
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
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
            //2
                  activeStep < 0 ? 'Next' : 'Submit',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  // Placeholder for submission logic
  void _nextOrSubmit() {
    if (activeStep == 0 && _validateStep1()) {
      _submitForm();
      // setState(() => activeStep = 1);
      // _scrollController.animateTo(
      //   0,
      //   duration: const Duration(milliseconds: 400),
      //   curve: Curves.easeInOut,
      // );
    } else if (activeStep == 1 && _validateStep2()) {
      _submitForm();
    }
  }

  // Stepper Indicators
  Widget _buildStepperIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepIndicator(0, 'Personal Info'),
        _buildStepIndicator(1, 'Teaching Details'),
        _buildStepIndicator(2, 'Upload CV'),
      ],
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final bool isActive = activeStep == stepIndex;
    final bool isCompleted = activeStep > stepIndex;

    Color indicatorColor;
    Color textColor;
    if (isCompleted) {
      indicatorColor = Colors.green;
      textColor = Colors.green;
    } else if (isActive) {
      indicatorColor = Colors.green;
      textColor = Colors.green;
    } else {
      indicatorColor = Colors.grey.shade400;
      textColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: () {
        // Only allow tapping to previous steps for review, or the current step
        if (stepIndex <= activeStep) {
          setState(() => activeStep = stepIndex);
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // <-- Border color
            width: 1, // <-- Border width
          ),
          borderRadius: BorderRadius.circular(
            25,
          ), // <-- Optional rounded corners
        ),
        child: Row(
          spacing: 2,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: indicatorColor, width: 2),
                color: isCompleted ? indicatorColor : Colors.white,
              ),
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 12)
                  : isActive
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: indicatorColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (activeStep) {
      case 0:
        return _step1Personal();
      case 1:
        return _step2Study();
      default:
        return const SizedBox.shrink();
    }
  }

  // Header Widget
  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circularButton(
              Icons.arrow_back,
              () => context.go('/signup-stepper'),
            ),
            // SizedBox(width: 100),
            _circularButton(Icons.question_mark_sharp, () {}),
          ],
        ),
        const SizedBox(height: 30),
        const Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "I'm a Student",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Please fill your personal details",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _circularButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white60,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, fontWeight: FontWeight.bold),
        iconSize: 20,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  // -------- STEP 1 UI --------
  Widget _step1Personal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _fStep1,
        child: Column(
          children: [
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),

            _tf(_studentNameCtrl, 'Student Name', validator: _req),

            const SizedBox(height: 20),
            _buildTwoColumnTextFields(
              _tf(
                _emailCtrl,
                'Email Id',
                keyboardType: TextInputType.emailAddress,
                validator: _email,
              ),
              // const SizedBox(height: 20),
              _tf(_parentNameCtrl, 'Parent Name', validator: _req),
            ),
            const SizedBox(height: 20),
            // _tf(
            //   _phoneCtrl,
            //   'Phone',
            //   keyboardType: TextInputType.phone,
            //   validator: _phone,
            // ),
            _tf(_addressCtrl, 'Address', validator: _req),
            const SizedBox(height: 20),
            _buildTwoColumnTextFields(
              _tf(_cityCtrl, 'City', validator: _req),
              _tf(
                _postalCtrl,
                'Postal Code',
                keyboardType: TextInputType.number,
                validator: _req,
              ),
            ),
            const SizedBox(height: 20),
            _buildTwoColumnTextFields(
              _tf(_districtCtrl, 'District', validator: _req),
              _tf(_stateCtrl, 'State', validator: _req),
            ),
            const SizedBox(height: 20),
            _tf(_countryCtrl, 'Country', validator: _req),
          ],
        ),
      ),
    );
  }

  // -------- STEP 2 UI --------
  Widget _step2Study() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _fStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mode of Learning Interest",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: "offline",
                    groupValue: _interest,
                    title: const Text("Offline"),
                    onChanged: (v) => setState(() => _interest = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: "online",
                    groupValue: _interest,
                    title: const Text("Online"),
                    onChanged: (v) => setState(() => _interest = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: "both",
                    groupValue: _interest,
                    title: const Text("Both"),
                    onChanged: (v) => setState(() => _interest = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Teaching Grade",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: listingGrades.map((grade) {
                final id = grade['id'].toString();
                final name = grade['name'].toString();
                final value = grade['value'].toString();
                final selected = _selectedGrades.contains(value);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v
                          ? _selectedGrades.add(value)
                          : _selectedGrades.remove(value);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ✅ Dynamic Subjects
            const Text(
              "Teaching Subjects",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: listingSubjects.map((subject) {
                final id = subject["id"].toString();
                final name = subject["name"].toString();
                final value = subject["value"].toString();

                return FilterChip(
                  label: Text(name),
                  selected: id == "other"
                      ? _other // 👈 special case
                      : _selectedSubjects.contains(value),
                  onSelected: (v) {
                    setState(() {
                      if (id == "other") {
                        _other = v;
                        if (!v) _otherSubjectCtrl.clear();
                      } else {
                        v
                            ? _selectedSubjects.add(value)
                            : _selectedSubjects.remove(value);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_other) ...[
              const SizedBox(height: 20),
              const Text(
                "Enter except above other subject",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _tf(
                _otherSubjectCtrl,
                "Enter other subject",
                validator: (v) => _other ? _req(v) : null,
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              "Preferable Learning Days",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _days.map((day) {
                final selected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v ? _selectedDays.add(day) : _selectedDays.remove(day);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Preferable Learning Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _hours.map((time) {
                final selected = _selectedHours.contains(time);
                return FilterChip(
                  label: Text(time),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v
                          ? _selectedHours.add(time)
                          : _selectedHours.remove(time);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Shared TextField --------
  // Widget _tf(
  //   TextEditingController c,
  //   String label, {
  //   TextInputType? keyboardType,
  //   String? Function(String?)? validator,
  // }) {
  //   return TextFormField(
  //     controller: c,
  //     validator: validator,
  //     keyboardType: keyboardType,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       floatingLabelBehavior: FloatingLabelBehavior.always,
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
  //     ),
  //   );
  // }

  // Helper for two text fields in a row
  Widget _buildTwoColumnTextFields(Widget tf1, Widget tf2) {
    return Row(
      children: [
        Expanded(child: tf1),
        const SizedBox(width: 15),
        Expanded(child: tf2),
      ],
    );
  }

  // Shared text field builder with updated styling
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
        hintText: label, // Use hintText for a cleaner look when not focused
        alignLabelWithHint: true,
        floatingLabelBehavior:
            FloatingLabelBehavior.never, // Label stays as hint
        filled: true,
        fillColor: Colors.grey.shade100, // Light background for text fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 1.5,
          ), // Green border on focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }


  void _showReferralPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return ReferralPopup(parentContext: context,
            redirectionUrl: '/student-dashboard');
      },
    );
  }
}
