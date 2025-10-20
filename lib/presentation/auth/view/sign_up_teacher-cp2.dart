import 'dart:io' show File; // Works only on mobile/desktop
import 'dart:typed_data';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/enums/app_config.dart';
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
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Step 1 Controllers
  final _fStep1 = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  PlatformFile? _avatarFile;
  Uint8List? _avatarBytes;
  String? _avatarName;

  PlatformFile? cvFile;
  Uint8List? _cvBytes;
  String? _cvName;

  // Step 2 Controllers
  final _fStep2 = GlobalKey<FormState>();
  // ====== STEP 3: CV upload ======
  final _fStep3 = GlobalKey<FormState>();

  String _interest = "offline"; // offline | online | both
  final _offlineExpCtrl = TextEditingController(text: "0");
  final _onlineExpCtrl = TextEditingController(text: "0");
  final _homeExpCtrl = TextEditingController(text: "0");

  bool _allSubjects = false;
  bool _other = false;
  final _otherSubjectCtrl = TextEditingController();

  String _profession = 'Teacher';
  String _readyToWork = 'Yes';
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<String> _selectedDays = [];
  final List<String> _hours = [
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

  // API data
  List<Map<String, dynamic>> listingGrades = [];
  List<Map<String, dynamic>> listingSubjects = [];
  List<String> _selectedGrades = [];
  List<String> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
          {"id": "other", "name": "Other", "value" : 'other'}, // 👈 always append
        ];
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  // ---------- Validators ----------
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
  Future<void> pickAvatar() async {
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

  Future<void> pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      final file = result.files.first;
      if (file.size > 3 * 1024 * 1024) {
        // 3 MB limit
        _toast("CV size must be less than 3 MB");
        return;
      }

      setState(() {
        cvFile = result.files.first;
        _cvBytes = result.files.first.bytes;
        _cvName = result.files.first.name;
      });
    }
  }

  // ---------- Step Validation ----------
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
      _toast('Please select a profile image');
      return false;
    }
  }

  bool _validateStep2() {
    final ok = _fStep2.currentState?.validate() ?? false;
    if (!ok) return false;
    if (_selectedGrades.isEmpty) {
      _toast('Select at least one grade');
      return false;
    }
    if (_selectedSubjects.isEmpty && !_other) {
      _toast('Select at least one subject');
      return false;
    }
    if (_other && _otherSubjectCtrl.text.trim().isEmpty) {
      _toast('Enter other subject');
      return false;
    }
    if (_selectedDays.isEmpty) {
      _toast('Select at least one working day');
      return false;
    }
    if (_selectedHours.isEmpty) {
      _toast('Select at least one working hour');
      return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (cvFile == null && _cvBytes == null) {
      _toast('Please upload your CV');
      return false;
    }

    if (cvFile != null && cvFile!.size > 3 * 1024 * 1024) {
      _toast("CV size must be less than 3 MB");
      return false;
    }

    return true;
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ---------- Submit ----------
  Future<void> _submitForm() async {
    final experience =
        "${_offlineExpCtrl.text},${_onlineExpCtrl.text},${_homeExpCtrl.text}";

    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];
    // final userId = userData?['id'];
    final userId = await LaunchStatusService.getUserId();

    print("*******");
    print(authState.userData);
    print("*******");

    final formData = {
      "avatar": _avatarFile,
      "teacher_id": userId,
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
      "teachingGrades": _selectedGrades,
      "teachingSubjects": [
        ..._selectedSubjects,
        if (_other && _otherSubjectCtrl.text.trim().isNotEmpty)
          _otherSubjectCtrl.text.trim(),
      ],
      "cvFile": cvFile,
    };

    setState(() => _isLoading = true);

    try {
      print(formData);
      final response = await container.read(
        teacherSignupProvider(formData).future,
      );
      // print(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Registration Successful"),
        ),
      );

      final userRole = response['user']?['acc_type'] ?? 'teacher';
      final user = response['user'];

      print(user);

      if (user != null) {
        await LaunchStatusService.saveUserData(user);
        await LaunchStatusService.setUserRole(userRole);
        // await LaunchStatusService.setUserId(userId);
        context.go('/teacher-dashboard', extra: {'teacherId': userId});
      }
    } catch (e) {
      print(e);
      _toast("❌ Error: $e");
    } finally {
      setState(() => _isLoading = false);
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
          // Background image
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
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please fill your personal details',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
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
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          EasyStepper(
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
                          // EasyStepper(
                          //   activeStep: activeStep,
                          //   lineLength: 50,
                          //   steps: const [
                          //     EasyStep(title: 'Step 1'),
                          //     EasyStep(title: 'Step 2'),
                          //     EasyStep(title: 'Step 3'),
                          //   ],
                          // ),
                          // const SizedBox(height: 0),
                          if (activeStep == 0) _step1Personal(),
                          if (activeStep == 1) _step2Teaching(),
                          if (activeStep == 2) _step3CV(),
                          const SizedBox(height: 20),
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
                                    onPressed: () =>
                                        setState(() => activeStep--),
                                    child: const Text('Back'),
                                  ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _nextOrSubmit,
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          activeStep < 2 ? 'Next' : 'Submit',
                                        ),
                                ),
                                SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ],
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

  void _nextOrSubmit() {
    if (activeStep == 0 && _validateStep1()) {
      setState(() => activeStep++);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (activeStep == 1 && _validateStep2()) {
      setState(() => activeStep++);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (activeStep == 2 && _validateStep3()) {
      _submitForm();
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
            const SizedBox(height: 5),
            Center(
              child: GestureDetector(
                onTap: pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _avatarFile != null
                      ? (kIsWeb
                            ? MemoryImage(_avatarFile!.bytes!)
                            : FileImage(
                                    // ignore: unnecessary_non_null_assertion
                                    File(_avatarFile!.path!),
                                  )
                                  as ImageProvider)
                      : null,
                  child: _avatarFile == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white,
                        ),
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
            // Wrap(
            //   spacing: 8,
            //   children: [
            //     FilterChip(
            //       label: const Text("Lower Primary"),
            //       selected: _lowerPrimary,
            //       onSelected: (v) => setState(() => _lowerPrimary = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Up to 10th"),
            //       selected: _upto10,
            //       onSelected: (v) => setState(() => _upto10 = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Higher Secondary"),
            //       selected: _higherSecondary,
            //       onSelected: (v) => setState(() => _higherSecondary = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Graduate Level"),
            //       selected: _graduate,
            //       onSelected: (v) => setState(() => _graduate = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Post Graduate Level"),
            //       selected: _postGraduate,
            //       onSelected: (v) => setState(() => _postGraduate = v),
            //     ),
            //   ],
            // ),
            Wrap(
              spacing: 8,
              children: listingGrades.map((grade) {
                final id = grade['id'].toString();
                final name = grade['name'].toString();
                final value = grade["value"].toString();

                final selected = _selectedGrades.contains(value);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v ? _selectedGrades.add(value) : _selectedGrades.remove(value);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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

            // Wrap(
            //   spacing: 8,
            //   children: [
            //     FilterChip(
            //       label: const Text("All Subjects"),
            //       selected: _allSubjects,
            //       onSelected: (v) => setState(() => _allSubjects = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Mathematics"),
            //       selected: _maths,
            //       onSelected: (v) => setState(() => _maths = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Science"),
            //       selected: _science,
            //       onSelected: (v) => setState(() => _science = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Malayalam"),
            //       selected: _malayalam,
            //       onSelected: (v) => setState(() => _malayalam = v),
            //     ),
            //     FilterChip(
            //       label: const Text("English"),
            //       selected: _english,
            //       onSelected: (v) => setState(() => _english = v),
            //     ),
            //     FilterChip(
            //       label: const Text("Other"),
            //       selected: _other,
            //       onSelected: (v) => setState(() => _other = v),
            //     ),
            //   ],
            // ),
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
              onTap: pickCV,
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
                            ? "Picked: ${cvFile!.name}"
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
