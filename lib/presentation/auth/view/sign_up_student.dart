import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:file_picker/file_picker.dart';
import '../../../services/launch_status_service.dart';
import '../controller/auth_controller.dart';
import '../providers/student_provider.dart';

class SignUpStudent extends StatefulWidget {
  const SignUpStudent({super.key});

  @override
  State<SignUpStudent> createState() => _SignUpStudentState();
}

class _SignUpStudentState extends State<SignUpStudent> {
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

  File? _avatarFile;
  Uint8List? _avatarBytes; // For web
  String? _avatarName; // Store filename for web

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

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      if (kIsWeb) {
        // On Web
        setState(() {
          _avatarFile = null;
          _avatarBytes = result.files.single.bytes;
          _avatarName = result.files.single.name;
        });
      } else {
        // On Mobile/Desktop
        setState(() {
          _avatarFile = File(result.files.single.path!);
        });
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No image selected')));
    }
  }

  // ---------- Step validators ----------
  bool _validateStep1() => _fStep1.currentState?.validate() ?? false;
  bool _validateStep2() => _fStep2.currentState?.validate() ?? false;

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---------- Submit ----------
  Future<void> _submitForm() async {
    if (_isLoading) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];
    final userId = userData?['id'];

    final formData = {
      "student_id": userId?.toString(),
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
      "seekingGrades": [
        if (_lowerPrimary) "lowerPrimary",
        if (_upto10) "upto10",
        if (_higherSecondary) "higherSecondary",
        if (_graduate) "graduate",
        if (_postGraduate) "postGraduate",
      ],
      "seekingSubjects": [
        if (_allSubjects) "all",
        if (_maths) "maths",
        if (_science) "science",
        if (_malayalam) "malayalam",
        if (_english) "english",
        if (_other) _otherSubjectCtrl.text.trim(),
      ],
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

      await LaunchStatusService.setUserRole(userRole);
      await LaunchStatusService.setUserId(userId!.toString());

      setState(() => _isLoading = true); // ⏳ Show loader

      // context.go('/student-dashboard');
      context.go('/student-dashboard', extra: {'studentId': userId.toString()});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background/full-bg.jpg'),
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
                          'I\'m a Student',
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
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0,
                          ),
                          child: EasyStepper(
                            steppingEnabled: false,
                            internalPadding: 60,
                            activeStep: activeStep,
                            fitWidth: true,
                            stepShape: StepShape.circle,
                            stepBorderRadius: 10,
                            borderThickness: 2,
                            stepRadius: 10,
                            lineStyle: const LineStyle(
                              lineSpace: 4,
                              lineType: LineType.normal,
                            ),
                            finishedStepBorderColor: Colors.green,
                            finishedStepTextColor: Colors.green,
                            finishedStepBackgroundColor: Colors.green,
                            activeStepBorderColor: Colors.green,
                            activeStepBackgroundColor: Colors.green,
                            unreachedStepBorderColor: Colors.grey,
                            unreachedStepBackgroundColor: Colors.grey,
                            showLoadingAnimation: true,
                            showStepBorder: true,
                            steps: const [
                              EasyStep(
                                customTitle: Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Center(
                                    child: Text('Personal Details'),
                                  ),
                                ),
                                customStep: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(radius: 3),
                                ),
                              ),
                              EasyStep(
                                customTitle: Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Center(child: Text('Study Details')),
                                ),
                                customStep: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(radius: 3),
                                ),
                              ),
                            ],
                            onStepReached: (index) =>
                                setState(() => activeStep = index),
                          ),
                        ),

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
                                onPressed: () {
                                  if (activeStep == 0) {
                                    if (_validateStep1()) {
                                      setState(() => activeStep = 1);
                                    }
                                  } else {
                                    if (_validateStep2()) {
                                      _submitForm();
                                    }
                                  }
                                },
                                child: Text(
                                  activeStep == 1 ? 'Submit' : 'Next',
                                ),
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
    switch (activeStep) {
      case 0:
        return _step1Personal();
      case 1:
        return _step2Study();
      default:
        return const SizedBox.shrink();
    }
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
                      ? FileImage(_avatarFile!) // Mobile/Desktop
                      : _avatarBytes != null
                      ? MemoryImage(_avatarBytes!)
                            as ImageProvider // Web
                      : null,
                  child: (_avatarFile == null && _avatarBytes == null)
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
            _tf(_parentNameCtrl, 'Parent Name', validator: _req),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _tf(_addressCtrl, 'Address', validator: _req),
            const SizedBox(height: 20),
            _tf(_cityCtrl, 'City', validator: _req),
            const SizedBox(height: 20),
            _tf(
              _postalCtrl,
              'Postal Code',
              keyboardType: TextInputType.number,
              validator: _req,
            ),
            const SizedBox(height: 20),
            _tf(_districtCtrl, 'District', validator: _req),
            const SizedBox(height: 20),
            _tf(_stateCtrl, 'State', validator: _req),
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
              children: [
                FilterChip(
                  label: const Text("Lower Primary"),
                  selected: _lowerPrimary,
                  onSelected: (v) => setState(() => _lowerPrimary = v),
                ),
                FilterChip(
                  label: const Text("Up to 10th"),
                  selected: _upto10,
                  onSelected: (v) => setState(() => _upto10 = v),
                ),
                FilterChip(
                  label: const Text("Higher Secondary"),
                  selected: _higherSecondary,
                  onSelected: (v) => setState(() => _higherSecondary = v),
                ),
                FilterChip(
                  label: const Text("Graduate Level"),
                  selected: _graduate,
                  onSelected: (v) => setState(() => _graduate = v),
                ),
                FilterChip(
                  label: const Text("Post Graduate Level"),
                  selected: _postGraduate,
                  onSelected: (v) => setState(() => _postGraduate = v),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Teaching Subjects",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text("All Subjects"),
                  selected: _allSubjects,
                  onSelected: (v) => setState(() => _allSubjects = v),
                ),
                FilterChip(
                  label: const Text("Mathematics"),
                  selected: _maths,
                  onSelected: (v) => setState(() => _maths = v),
                ),
                FilterChip(
                  label: const Text("Science"),
                  selected: _science,
                  onSelected: (v) => setState(() => _science = v),
                ),
                FilterChip(
                  label: const Text("Malayalam"),
                  selected: _malayalam,
                  onSelected: (v) => setState(() => _malayalam = v),
                ),
                FilterChip(
                  label: const Text("English"),
                  selected: _english,
                  onSelected: (v) => setState(() => _english = v),
                ),
                FilterChip(
                  label: const Text("Other"),
                  selected: _other,
                  onSelected: (v) => setState(() => _other = v),
                ),
              ],
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
