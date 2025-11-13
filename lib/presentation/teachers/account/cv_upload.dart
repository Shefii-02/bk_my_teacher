// lib/features/profile/pages/cv_upload_page.dart
import 'dart:typed_data';
import 'package:BookMyTeacher/providers/teacher_profile_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';
import '../../../services/launch_status_service.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/providers/teacher_provider.dart';

class CvUpload extends ConsumerStatefulWidget {
  const CvUpload({super.key});

  @override
  ConsumerState<CvUpload> createState() => _CvUploadState();
}

class _CvUploadState extends ConsumerState<CvUpload> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  PlatformFile? cvFile;
  Uint8List? _cvBytes;
  late Future<Map<String, dynamic>> _teacherDataFuture;
  final ScrollController _scrollController = ScrollController();
  late Map<String, dynamic> teacherData;
  String? _cvUrl;
  String? _cvName;

  @override
  void initState() {
    super.initState();
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;
    if (user != null) {
      teacherData = user.toJson();
      debugPrint("✅ Teacher Data Received: $teacherData");

      _cvUrl = teacherData['cv_url'];
      print(teacherData['cv_url']);
    } else {
      teacherData = {};
    }
  }

  Future<Map<String, dynamic>> _fetchTeacherData() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);
    final userData = authState.userData?['data'];
    return userData ?? {};
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

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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

  // ---------- Submit ----------
  Future<void> _submitForm() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authControllerProvider);

    final formData = {"cvFile": cvFile};

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(teacherCvProvider(formData).future);
      // print(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Cv updated Successful"),
        ),
      );
      if (response["status"]) {
        // ✅ Then redirect
        // if (context.mounted)
        ref.refresh(userProvider.notifier).loadUser(silent: true);
        await Future.delayed(const Duration(seconds: 1));
        context.go('/teacher-dashboard');
      }
    } catch (e) {
      print(e);
      _toast("❌ Error: $e");
    } finally {
      setState(() => _isLoading = false);
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
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (_cvUrl != null)
                                    _existingCvPreview(context, _cvUrl!),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: pickCV,
                                    child: Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
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
                                                color: cvFile != null
                                                    ? Colors.black87
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  _submitButton(),
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

  Widget _existingCvPreview(BuildContext context, String cvUrl) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cvUrl.split('/').last,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {
              context.push('/pdf-view', extra: {'url': cvUrl});
            },
            child: const Text("View"),
          ),
        ],
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
                "Edit CV",
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

  Widget _submitButton() => Center(
    child: ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}
