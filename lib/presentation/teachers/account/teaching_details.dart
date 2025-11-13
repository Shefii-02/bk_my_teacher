import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/teacher_profile_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/launch_status_service.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/providers/teacher_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeachingDetails extends ConsumerStatefulWidget {
  const TeachingDetails({super.key});

  @override
  ConsumerState<TeachingDetails> createState() => _TeachingDetailsState();
}

class _TeachingDetailsState extends ConsumerState<TeachingDetails> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late Map<String, dynamic> teacherData;
  // Step 2 Controllers
  final _fStep2 = GlobalKey<FormState>();

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
  late List<String> _selectedDays = [];
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
  late List<String> _selectedHours = [];

  // API data
  List<Map<String, dynamic>> listingGrades = [];
  List<Map<String, dynamic>> listingSubjects = [];
  List<String> _selectedGrades = [];
  List<String> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;

    if (user != null) {
      teacherData = user.toJson();
      debugPrint("✅ Teacher Data Received: $teacherData");

      // ✅ Prefill your teaching details if available
      if (teacherData['professional'] != null) {
        final p = teacherData['professional'];

        _interest = p['teaching_mode'] ?? 'offline';
        _offlineExpCtrl.text = p['offline_exp']?.toString() ?? '0';
        _onlineExpCtrl.text = p['online_exp']?.toString() ?? '0';
        _homeExpCtrl.text = p['home_exp']?.toString() ?? '0';
        _profession = p['profession'] ?? 'Teacher';
        _readyToWork = p['ready_to_work'] ?? 'Yes';
        List<String> sGrades = (teacherData['grades'] as List)
            .map((item) => item['grade'].toString())
            .toList();

        List<String> sSubjects = (teacherData['subjects'] as List)
            .map((item) => item['subject'].toString())
            .toList();

        print(teacherData['working_days']);
        print(teacherData['working_hours']);

        List<String> aDays = (teacherData['working_days'] as List)
            .map((item) => item['day'].toString())
            .toList();

        List<String> aTimeSlots = (teacherData['working_hours'] as List)
            .map((item) => item['time_slot'].toString())
            .toList();

        // ✅ Ensure lists are not null
        _selectedGrades = sGrades ?? [];
        _selectedSubjects = sSubjects ?? [];
        _selectedDays = aDays ?? [];
        _selectedHours = aTimeSlots ?? [];

        // ✅ Handle “Other” subject logic
        if (_selectedSubjects.contains('other')) {
          _other = true;
          _otherSubjectCtrl.text = p['otherSubject'] ?? '';
        }
      }
    } else {
      teacherData = {};
    }
  }

  String? _nonNegInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null || n < 0) return 'Enter a non-negative number';
    return null;
  }

  Future<void> _loadData() async {
    final api = ApiService();
    try {
      final grades = await api.getListingGrades();
      final subjects = await api.getListingSubjects();
      setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Error fetching data: $e");
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

  // Placeholder for submission logic
  void _nextOrSubmit() {
    if (_validateStep2()) {
      _submitForm();
    }
  }

  // ---------- Validators (copied from your original code) ----------
  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[\w\.\-+]+@[\w\.\-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submitForm() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];
    // final userId = userData?['id'];
    final userId = await LaunchStatusService.getUserId();

    print("*******");
    print(authState.userData);
    print("*******");
    final formData = {
      "interest": _interest,
      "offline_exp": _offlineExpCtrl.text.trim(),
      "online_exp": _onlineExpCtrl.text.trim(),
      "home_exp": _homeExpCtrl.text.trim(),
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
    };
    setState(() => _isLoading = true);
print(formData);
    try {
      final response = await ref.read(teacherTeachingDetailsProvider(formData).future);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Updated Successfully")),
      );
      setState(() => _isLoading = true);
      if (response["status"]) {
        // ✅ Then redirect
        // if (context.mounted)
        ref.refresh(userProvider.notifier).loadUser(silent: true);
        await Future.delayed(
          const Duration(seconds: 1),
        );
        context.go('/teacher-dashboard');

      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      _toast("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }

    @override
    void dispose() {
      _offlineExpCtrl.dispose();
      _onlineExpCtrl.dispose();
      _homeExpCtrl.dispose();
      _otherSubjectCtrl.dispose();
      super.dispose();
    }
  }

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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Form(
                              key: _fStep2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Mode of Interest",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<String>(
                                          contentPadding: EdgeInsets.zero,
                                          value: "offline",
                                          groupValue: _interest,
                                          title: const Text("Offline"),
                                          onChanged: (v) =>
                                              setState(() => _interest = v!),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          contentPadding: EdgeInsets.zero,
                                          value: "online",
                                          groupValue: _interest,
                                          title: const Text("Online"),
                                          onChanged: (v) =>
                                              setState(() => _interest = v!),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          contentPadding: EdgeInsets.zero,
                                          value: "both",
                                          groupValue: _interest,
                                          title: const Text("Both"),
                                          onChanged: (v) =>
                                              setState(() => _interest = v!),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                  const Text(
                                    "Teaching Grade",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Wrap(
                                    spacing: 8,
                                    children: listingGrades.map((grade) {
                                      final id = grade['id'].toString();
                                      final name = grade['name'].toString();
                                      final value = grade["value"].toString();

                                      final selected = _selectedGrades.contains(
                                        value,
                                      );
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
                                  const Text(
                                    "Teaching Subjects",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                                  : _selectedSubjects.remove(
                                                      value,
                                                    );
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  keyboardType:
                                                      TextInputType.number,
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
                                                  keyboardType:
                                                      TextInputType.number,
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            child: RadioListTile<String>(
                                              title: const Text("Teacher"),
                                              value: 'Teacher',
                                              groupValue: _profession,
                                              onChanged: (v) => setState(
                                                () => _profession = v!,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: const Text("Student"),
                                              value: 'Student',
                                              groupValue: _profession,
                                              onChanged: (v) => setState(
                                                () => _profession = v!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      RadioListTile<String>(
                                        title: const Text("Seeking Job"),
                                        value: 'Seeking Job',
                                        groupValue: _profession,
                                        onChanged: (v) =>
                                            setState(() => _profession = v!),
                                      ),
                                    ],
                                  ),

                                  // Ready to work
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            child: RadioListTile<String>(
                                              contentPadding: EdgeInsets.zero,
                                              title: const Text("Yes"),
                                              value: 'Yes',
                                              groupValue: _readyToWork,
                                              onChanged: (v) => setState(
                                                () => _readyToWork = v!,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<String>(
                                              contentPadding: EdgeInsets.zero,
                                              title: const Text("No"),
                                              value: 'No',
                                              groupValue: _readyToWork,
                                              onChanged: (v) => setState(
                                                () => _readyToWork = v!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
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
                                      final selected = _selectedDays.contains(
                                        day,
                                      );
                                      return FilterChip(
                                        label: Text(day),
                                        selected: selected,
                                        onSelected: (v) {
                                          setState(() {
                                            v
                                                ? _selectedDays.add(day)
                                                : _selectedDays.remove(day);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 16),
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
                                      final selected = _selectedHours.contains(
                                        time,
                                      );
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
                                  const SizedBox(height: 30),
                                  _submitButton()
                                ],
                              ),
                            ),
                          ),
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
  Widget _submitButton() => Center(
    child: ElevatedButton(
      onPressed: _isLoading ? null : _nextOrSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding:
        const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
          : const Text(
        'Update',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

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
              () => context.go('/teacher-dashboard'),
            ),
            // SizedBox(width: 100),
          ],
        ),
        const SizedBox(height: 30),
        const Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Teaching Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
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
}
