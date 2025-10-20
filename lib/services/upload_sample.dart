import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class UploadSample extends StatefulWidget {
  const UploadSample({super.key});

  @override
  State<UploadSample> createState() => _UploadSampleState();
}

class _UploadSampleState extends State<UploadSample> {
  PlatformFile? avatarFile;
  PlatformFile? cvFile;
  bool isUploading = false;

  Future<void> pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        avatarFile = result.files.first;
      });
    }
  }

  Future<void> pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        cvFile = result.files.first;
      });
    }
  }

  Future<void> uploadFiles() async {
    if (avatarFile == null || cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both Avatar and CV")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final dio = Dio();
      const apiUrl =
          "https://bookmyteacher.shefii.com/api/upload"; // 🔴 Change to your Laravel API URL

      final formData = FormData();

      // Attach avatar
      if (kIsWeb) {
        formData.files.add(MapEntry(
          "avatar",
          MultipartFile.fromBytes(
            avatarFile!.bytes!,
            filename: avatarFile!.name,
          ),
        ));
      } else {
        formData.files.add(MapEntry(
          "avatar",
          await MultipartFile.fromFile(
            avatarFile!.path!,
            filename: avatarFile!.name,
          ),
        ));
      }

      // Attach CV
      if (kIsWeb) {
        formData.files.add(MapEntry(
          "cv",
          MultipartFile.fromBytes(
            cvFile!.bytes!,
            filename: cvFile!.name,
          ),
        ));
      } else {
        formData.files.add(MapEntry(
          "cv",
          await MultipartFile.fromFile(
            cvFile!.path!,
            filename: cvFile!.name,
          ),
        ));
      }

      // Add request source info
      final headers = {
        "X-Request-Source": kIsWeb ? "WebBrowser" : "MobileOrDesktopApp",
      };

      final response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(headers: headers),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Upload success: ${response.data}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed: $e")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Avatar & CV")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Show avatar in CircleAvatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatarFile != null
                  ? (kIsWeb
                  ? MemoryImage(avatarFile!.bytes!)
                  : FileImage(
                // ignore: unnecessary_non_null_assertion
                File(avatarFile!.path!),
              ) as ImageProvider)
                  : null,
              child: avatarFile == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: pickAvatar,
              icon: const Icon(Icons.image),
              label: Text(avatarFile == null
                  ? "Pick Avatar (Image)"
                  : "Picked: ${avatarFile!.name}"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickCV,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(cvFile == null
                  ? "Pick CV (PDF/DOC)"
                  : "Picked: ${cvFile!.name}"),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isUploading ? null : uploadFiles,
              icon: const Icon(Icons.cloud_upload),
              label: Text(isUploading ? "Uploading..." : "Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
