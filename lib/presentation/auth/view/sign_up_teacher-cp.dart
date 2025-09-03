import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../routes/app_router.dart';
import '../../../services/launch_status_service.dart';
import '../../../services/teacher_api_service.dart';
import '../controller/auth_controller.dart';
import '../providers/teacher_provider.dart';

class SignUpTeacher extends StatefulWidget {
  const SignUpTeacher({super.key});

  @override
  State<SignUpTeacher> createState() => _SignUpTeacherState();
}

class _SignUpTeacherState extends State<SignUpTeacher> {
  int activeStep = 0;

  String name = '';
  String email = '';
  String _address = '';
  String _city = '';
  String _postalCode = '';
  String _district = '';
  String _state = '';
  String _country = '';
  String subject = '';
  String experience = '';
  File? _avatarFile;
  File? cvFile;

  final ImagePicker _picker = ImagePicker();

  // Experience controllers
  final TextEditingController _offlineExpController = TextEditingController();
  final TextEditingController _onlineExpController = TextEditingController();
  final TextEditingController _homeTuitionExpController =
      TextEditingController();

  // Mode of Interest
  String _interest = "offline"; // default selection

  bool _offline = false;
  bool _online = false;
  bool _both = false;

  // Teaching Grade
  bool _lowerPrimary = false;
  bool _upto10 = false;
  bool _higherSecondary = false;
  bool _graduate = false;
  bool _postGraduate = false;

  // Teaching Subjects
  bool _allSubjects = false;
  bool _maths = false;
  bool _science = false;
  bool _malayalam = false;
  bool _english = false;
  bool _other = false;
  final TextEditingController _otherSubjectController = TextEditingController();

  String _profession = 'Teacher';
  String _readyToWork = 'Yes';

  final List<String> _days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
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

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        cvFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickAvatar() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } else {
      print("Permission denied");
    }
  }

  Future<void> _submitForm() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];

    var userId = userData?['id'];
    var userMobile = userData?['mobile'];

    print('*******');
    print(authState.userData);
    print('*******');

    print("User ID: $userId");
    print("User Mobile: $userMobile");
    // For testing - remove this line in production
    // userId = 28;

    if (_avatarFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an avatar image")),
      );
      return;
    }

    if (cvFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a CV file")));
      return;
    }

    // Create experience string from all three fields
    String experience =
        "${_offlineExpController.text},${_onlineExpController.text},${_homeTuitionExpController.text}";

    final formData = {
      "avatar": _avatarFile,
      "teacher_id": userId.toString(),
      "name": name,
      "email": email,
      "address": _address,
      "city": _city,
      "postalCode": _postalCode,
      "district": _district,
      "state": _state,
      "country": _country,
      "interest" : _interest,
      "offline_exp": _offlineExpController.text,
      "online_exp": _onlineExpController.text,
      "home_exp": _homeTuitionExpController.text,
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
        if (_other) _otherSubjectController.text,
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

      final responseData = response['data'];
      final userRole = response['user']?['acc_type'] ?? 'guest';
      print('*********************');
      print(userRole);
      print('*********************');
      await LaunchStatusService.setUserRole(userRole);

      // Navigate
      context.go('/teacher-dashboard');
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Widget _buildStepContent() {
    switch (activeStep) {
      case 0:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 0,
              ),
              child: Column(
                children: [
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
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email Id',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => email = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => _address = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'City',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => _city = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Postal code',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => _postalCode = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'District',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => _district = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'State',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => _state = val,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Country',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (val) => _country = val,
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode of Interest
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
                      groupValue: _interest, // <-- important
                      title: const Text("Offline"),
                      onChanged: (v) => setState(() => _interest = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: "online",
                      groupValue: _interest, // <-- important
                      title: const Text("Online"),
                      onChanged: (v) => setState(() => _interest = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: "both",
                      groupValue: _interest, // <-- important
                      title: const Text("Both"),
                      onChanged: (v) => setState(() => _interest = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Teaching Grade
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
              // Teaching Subjects
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
                TextField(
                  controller: _otherSubjectController,
                  decoration: InputDecoration(
                    labelText: "Enter other subject",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: Offline + Online
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
                            TextField(
                              controller: _offlineExpController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              keyboardType: TextInputType.number,
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
                            TextField(
                              controller: _onlineExpController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Second row: Home Tuition
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Years of experience in Home tuition",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _homeTuitionExpController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Working Profession",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text("Teacher"),
                              value: 'Teacher',
                              groupValue: _profession,
                              onChanged: (value) {
                                setState(() => _profession = value!);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text("Student"),
                              value: 'Student',
                              groupValue: _profession,
                              onChanged: (value) {
                                setState(() => _profession = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      RadioListTile(
                        title: const Text("Seeking Job"),
                        value: 'Seeking Job',
                        groupValue: _profession,
                        onChanged: (value) {
                          setState(() => _profession = value!);
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ready To Work with BookMyTeacher as Full-time Faculty with Monthly Salary",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("Yes"),
                              value: 'Yes',
                              groupValue: _readyToWork,
                              onChanged: (value) {
                                setState(() => _readyToWork = value!);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("No"),
                              value: 'No',
                              groupValue: _readyToWork,
                              onChanged: (value) {
                                setState(() => _readyToWork = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Preferable Working Days
                      const Text(
                        "Preferable Working Days",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: _days.map((day) {
                          return FilterChip(
                            label: Text(day),
                            selected: _selectedDays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                selected
                                    ? _selectedDays.add(day)
                                    : _selectedDays.remove(day);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Preferable Working Hours
                      const Text(
                        "Preferable Working Hours",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: _hours.map((time) {
                          return FilterChip(
                            label: Text(time),
                            selected: _selectedHours.contains(time),
                            onSelected: (selected) {
                              setState(() {
                                selected
                                    ? _selectedHours.add(time)
                                    : _selectedHours.remove(time);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload Your CV",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Upload Box
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
                            color: cvFile != null
                                ? Colors.black87
                                : Colors.black,
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
        );
      default:
        return Container();
    }
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
                        onPressed: () {
                          context.go('/signup-stepper');
                        },
                      ),
                    ),
                    // Title
                    Column(
                      children: const [
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
              // Main White Rounded Body
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                customStep: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(radius: 3),
                                ),
                                customTitle: Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Center(child: Text('Upload CV')),
                                ),
                              ),
                            ],
                            onStepReached: (index) {
                              setState(() => activeStep = index);
                            },
                          ),
                        ),
                        _buildStepContent(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (activeStep > 0)
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      activeStep--;
                                    });
                                  },
                                  child: const Text('Back'),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (activeStep < 2) {
                                    setState(() {
                                      activeStep++;
                                    });
                                  } else {
                                    _submitForm();
                                  }
                                },
                                child: Text(
                                  activeStep == 2 ? 'Submit' : 'Next',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
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
}
