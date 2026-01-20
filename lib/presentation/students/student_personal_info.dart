import 'package:BookMyTeacher/presentation/students/providers/student_personal_info_provider.dart';
import 'package:BookMyTeacher/providers/teacher_profile_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';

class StudentPersonalInfo extends ConsumerStatefulWidget {
  const StudentPersonalInfo({super.key});

  @override
  ConsumerState<StudentPersonalInfo> createState() => _StudentPersonalInfoState();
}

class _StudentPersonalInfoState extends ConsumerState<StudentPersonalInfo> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

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
  String? _avatarUrl;

  late Map<String, dynamic> teacherData;

  @override
  void initState() {
    super.initState();

    // ✅ use ref.read() instead of ref.watch()
    // WidgetsBinding.instance.addPostFrameCallback((_) {
      final userAsync = ref.read(userProvider);
      final user = userAsync.value;

      if (user != null) {
        teacherData = user.toJson();
        debugPrint("✅ User Data Received: $teacherData");

        _nameCtrl.text = teacherData['name'] ?? '';
        _emailCtrl.text = teacherData['email'] ?? '';
        _addressCtrl.text = teacherData['address'] ?? '';
        _cityCtrl.text = teacherData['city'] ?? '';
        _postalCtrl.text = teacherData['postal_code']?.toString() ?? '';
        _districtCtrl.text = teacherData['district'] ?? '';
        _stateCtrl.text = teacherData['state'] ?? '';
        _countryCtrl.text = teacherData['country'] ?? '';
        _avatarUrl = teacherData['avatar_url'];
      } else {
        teacherData = {};
      }

    // });
  }

  Future<void> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = result.files.first;
      if (file.size > 2 * 1024 * 1024) {
        _toast("Profile Pic size must be less than 2 MB");
        return;
      }
      setState(() => _avatarFile = file);
    }
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[\w\.\-+]+@[\w\.\-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  bool _validateStep1() {
    final ok = _fStep1.currentState?.validate() ?? false;
    if (!ok) return false;
    if (_avatarFile == null && _avatarUrl == null) {
      _toast('Please select a profile image');
      return false;
    }
    return true;
  }

  void _nextOrSubmit() {
    if (_validateStep1()) _submitForm();
  }

  Future<void> _submitForm() async {
    final formData = {
      "avatar": _avatarFile,
      "name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "address": _addressCtrl.text.trim(),
      "city": _cityCtrl.text.trim(),
      "postalCode": _postalCtrl.text.trim(),
      "district": _districtCtrl.text.trim(),
      "state": _stateCtrl.text.trim(),
      "country": _countryCtrl.text.trim(),
    };

    setState(() => _isLoading = true);
    try {
      final response = await ref.read(studentPersonalInfoProvider(formData).future);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Updated Successfully")),
      );
      setState(() => _isLoading = false);
      if (response["status"]) {
        // ✅ Then redirect
        // if (context.mounted)
        ref.refresh(userProvider.notifier).loadUser(silent: true);
        await Future.delayed(
          const Duration(seconds: 1),
        );
        context.go('/student-dashboard');
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      _toast("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    if (userAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _headerGradient(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 20),
                Expanded(child: _formContainer()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerGradient() => Container(
    width: double.infinity,
    height: 300,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF114887), Color(0xFF6DE899)],
      ),
    ),
  );

  Widget _formContainer() => Container(
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
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _fStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _avatarPicker()),
            const SizedBox(height: 15),
            _buildTwoColumnTextFields(
              _tf(_nameCtrl, 'Full Name', validator: _req),
              _tf(_emailCtrl, 'Email Id',
                  keyboardType: TextInputType.emailAddress,
                  validator: _email),
            ),
            const SizedBox(height: 15),
            _tf(_addressCtrl, 'Address', validator: _req),
            const SizedBox(height: 15),
            _buildTwoColumnTextFields(
              _tf(_cityCtrl, 'City', validator: _req),
              _tf(_postalCtrl, 'Postal Code',
                  keyboardType: TextInputType.number, validator: _req),
            ),
            const SizedBox(height: 15),
            _buildTwoColumnTextFields(
              _tf(_districtCtrl, 'District', validator: _req),
              _tf(_stateCtrl, 'State', validator: _req),
            ),
            const SizedBox(height: 15),
            _tf(_countryCtrl, 'Country', validator: _req),
            const SizedBox(height: 30),
            _submitButton(),
          ],
        ),
      ),
    ),
  );

  Widget _avatarPicker() => GestureDetector(
    onTap: pickAvatar,
    child: Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: _avatarFile != null
              ? (kIsWeb
              ? MemoryImage(_avatarFile!.bytes!)
              : FileImage(File(_avatarFile!.path!)) as ImageProvider)
              : (_avatarUrl != null && _avatarUrl!.isNotEmpty
              ? NetworkImage(_avatarUrl!)
              : null),
          child: (_avatarFile == null && _avatarUrl == null)
              ? Icon(Icons.person, size: 50, color: Colors.grey[500])
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt,
                color: Colors.white, size: 18),
          ),
        ),
      ],
    ),
  );

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

  Widget _buildTwoColumnTextFields(Widget tf1, Widget tf2) => Row(
    children: [
      Expanded(child: tf1),
      const SizedBox(width: 15),
      Expanded(child: tf2),
    ],
  );

  Widget _tf(TextEditingController c, String label,
      {TextInputType? keyboardType,
        String? Function(String?)? validator}) =>
      TextFormField(
        controller: c,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.green, width: 1.5),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _buildHeader() => Column(
    children: [
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circularButton(Icons.arrow_back, () => context.pop()),
        ],
      ),
      const SizedBox(height: 30),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Edit Personal Info",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );

  Widget _circularButton(IconData icon, VoidCallback onPressed) => Container(
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
      icon: Icon(icon, color: Colors.black87),
      iconSize: 20,
      onPressed: onPressed,
    ),
  );
}
