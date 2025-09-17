import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// keep your own imports if you use them in _submitForm
import '../../../services/launch_status_service.dart';
import '../controller/auth_controller.dart';
import '../providers/teacher_provider.dart';

class SignUpTeacher extends StatefulWidget {
  const SignUpTeacher({super.key});

  @override
  State<SignUpTeacher> createState() => _SignUpTeacherState();
}

class _SignUpTeacherState extends State<SignUpTeacher> {
  int activeStep = 0;

  // ====== STEP 1: Personal Info controllers ======
  final _fStep1 = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  File? _avatarFile;

  // ====== STEP 2: Teaching Details ======
  final _fStep2 = GlobalKey<FormState>();

  // Mode of Interest (radio)
  String _interest = "offline"; // offline | online | both

  // Experience (all required numeric)
  final _offlineExpCtrl = TextEditingController(text: "0");
  final _onlineExpCtrl = TextEditingController(text: "0");
  final _homeExpCtrl = TextEditingController(text: "0");

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

  // Profession (radio)
  String _profession = 'Teacher';

  // Ready to work (radio)
  String _readyToWork = 'Yes';

  // Preferable Days & Hours (chips)
  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
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

  // ====== STEP 3: CV upload ======
  final _fStep3 = GlobalKey<FormState>();
  File? cvFile;

  final ImagePicker _picker = ImagePicker();

  // ---------- Helpers: validators ----------
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[\w\.\-+]+@[\w\.\-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  String? _nonNegInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Enter a non-negative number';
    return null;
  }

  // ---------- Pickers ----------
  Future<void> _pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => cvFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickAvatar() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _avatarFile = File(image.path));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photos permission denied')));
    }
  }

  // ---------- Step validators ----------
  bool _validateStep1() {
    final ok = _fStep1.currentState?.validate() ?? false;
    if (!ok) return false;

    if (_avatarFile == null) {
      _toast('Please select an avatar image');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final ok = _fStep2.currentState?.validate() ?? false;
    if (!ok) return false;

    if (!(_lowerPrimary ||
        _upto10 ||
        _higherSecondary ||
        _graduate ||
        _postGraduate)) {
      _toast('Please select at least one Teaching Grade');
      return false;
    }
    if (!(_allSubjects ||
        _maths ||
        _science ||
        _malayalam ||
        _english ||
        _other)) {
      _toast('Please select at least one Teaching Subject');
      return false;
    }
    if (_other && _otherSubjectCtrl.text.trim().isEmpty) {
      _toast('Please enter the Other subject');
      return false;
    }
    if (_selectedDays.isEmpty) {
      _toast('Please select at least one working day');
      return false;
    }
    if (_selectedHours.isEmpty) {
      _toast('Please select at least one working hour');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (cvFile == null) {
      _toast('Please upload your CV');
      return false;
    }
    return true;
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---------- Submit ----------
  Future<void> _submitForm() async {
    // Collect experience string
    final experience =
        "${_offlineExpCtrl.text},${_onlineExpCtrl.text},${_homeExpCtrl.text}";

    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];
    final userId = userData?['id'];
    final userMobile = userData?['mobile'];

    debugPrint("User ID: $userId | Mobile: $userMobile");

    final formData = {
      "avatar": _avatarFile,
      "teacher_id": userId?.toString(),
      "name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "address": _addressCtrl.text.trim(),
      "city": _cityCtrl.text.trim(),
      "postalCode": _postalCtrl.text.trim(),
      "district": _districtCtrl.text.trim(),
      "state": _stateCtrl.text.trim(),
      "country": _countryCtrl.text.trim(),
      "interest": _interest,
      "offline_exp": _offlineExpCtrl.text.trim(),
      "online_exp": _onlineExpCtrl.text.trim(),
      "home_exp": _homeExpCtrl.text.trim(),
      "experience": experience,
      "profession": _profession,
      "readyToWork": _readyToWork,
      "selectedDays": _selectedDays,
      "selectedHours": _selectedHours,
      "teachingGrades": [
        if (_lowerPrimary) "lowerPrimary",
        if (_upto10) "upto10",
        if (_higherSecondary) "higherSecondary",
        if (_graduate) "graduate",
        if (_postGraduate) "postGraduate",
      ],
      "teachingSubjects": [
        if (_allSubjects) "all",
        if (_maths) "maths",
        if (_science) "science",
        if (_malayalam) "malayalam",
        if (_english) "english",
        if (_other) _otherSubjectCtrl.text.trim(),
      ],
      "cvFile": cvFile,
    };

    try {
      final response = await container.read(
        teacherSignupProvider(formData).future,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Registration Successful"),
        ),
      );

      final userRole = response['user']?['acc_type'] ?? 'teacher';
      await LaunchStatusService.setUserRole(userRole);
      // print("**************");
      // print(userId!.toString());
      // print("**************");
      await LaunchStatusService.setUserId(userId!.toString());

      // print(response);
      // print('******************');
      // print(response['user']);
      // print('******************');
      // print('******************');
      // print(response['user']?['acc_type']);
      // print('******************');

      // print(LaunchStatusService.getUserRole());

      // print(userRole);
      context.go('/teacher-dashboard', extra: {'teacherId': userId});
      // context.go('/teacher-dashboard');
    } catch (e) {
      debugPrint("Submit error: $e");
      _toast("❌ Error: $e");
    }
  }

  // ---------- UI ----------
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _offlineExpCtrl.dispose();
    _onlineExpCtrl.dispose();
    _homeExpCtrl.dispose();
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
                          'I\'m a Teacher',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please fill your personal details',
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
                                  child: Center(child: Text('Personal Info')),
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
                                  child: Center(
                                    child: Text('Teaching Details'),
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
                                  child: Center(child: Text('Upload CV')),
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

                        SizedBox(
                          width: 450,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Step content (keeps your look)
                                _buildStepContent(),
                              ],
                            ),
                          ),
                        ),

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
                                    if (_validateStep1())
                                      setState(() => activeStep = 1);
                                  } else if (activeStep == 1) {
                                    if (_validateStep2())
                                      setState(() => activeStep = 2);
                                  } else {
                                    if (_validateStep3()) _submitForm();
                                  }
                                },
                                child: Text(
                                  activeStep == 2 ? 'Submit' : 'Next',
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
        return _step2Teaching();
      case 2:
        return _step3CV();
      default:
        return const SizedBox.shrink();
    }
  }

  // -------- STEP 1 UI (same style) --------
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
                      ? FileImage(_avatarFile!)
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
            _tf(_nameCtrl, 'Full Name', validator: _req),
            const SizedBox(height: 20),
            _tf(
              _emailCtrl,
              'Email Id',
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
            const SizedBox(height: 20),
            _tf(_addressCtrl, 'Address', validator: _req),
            const SizedBox(height: 20),
            _tf(_cityCtrl, 'City', validator: _req),
            const SizedBox(height: 20),
            _tf(
              _postalCtrl,
              'Postal code',
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

  // -------- STEP 2 UI (same style) --------
  Widget _step2Teaching() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _fStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mode of Interest",
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
            // Experience
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Years of experience in offline",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _tf(
                            _offlineExpCtrl,
                            "",
                            keyboardType: TextInputType.number,
                            validator: _nonNegInt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Years of experience in online",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _tf(
                            _onlineExpCtrl,
                            "",
                            keyboardType: TextInputType.number,
                            validator: _nonNegInt,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Years of experience in Home tuition",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _tf(
                  _homeExpCtrl,
                  "",
                  keyboardType: TextInputType.number,
                  validator: _nonNegInt,
                ),
                const SizedBox(height: 14),
              ],
            ),

            // Profession
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Current Working Profession",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Teacher"),
                        value: 'Teacher',
                        groupValue: _profession,
                        onChanged: (v) => setState(() => _profession = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Student"),
                        value: 'Student',
                        groupValue: _profession,
                        onChanged: (v) => setState(() => _profession = v!),
                      ),
                    ),
                  ],
                ),
                RadioListTile<String>(
                  title: const Text("Seeking Job"),
                  value: 'Seeking Job',
                  groupValue: _profession,
                  onChanged: (v) => setState(() => _profession = v!),
                ),
              ],
            ),

            // Ready to work
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ready To Work with BookMyTeacher as Full-time Faculty with Monthly Salary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Yes"),
                        value: 'Yes',
                        groupValue: _readyToWork,
                        onChanged: (v) => setState(() => _readyToWork = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("No"),
                        value: 'No',
                        groupValue: _readyToWork,
                        onChanged: (v) => setState(() => _readyToWork = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "Preferable Working Days",
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

            const SizedBox(height: 16),
            const Text(
              "Preferable Working Hours",
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

  // -------- STEP 3 UI (same style) --------
  Widget _step3CV() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _fStep3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload Your CV",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickCV,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cvFile != null
                            ? cvFile!.path.split('/').last
                            : 'Click to Upload CV',
                        style: TextStyle(
                          fontSize: 14,
                          color: cvFile != null ? Colors.black87 : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shared text field builder in your style
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
