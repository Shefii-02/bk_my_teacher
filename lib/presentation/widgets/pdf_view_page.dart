// lib/features/profile/pages/pdf_view_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class PdfViewPage extends StatefulWidget {
  final String url;
  const PdfViewPage({super.key, required this.url});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPdf();
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/temp_cv.pdf");
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View CV")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
          ? const Center(child: Text("Unable to load PDF"))
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("PDF Error: $error")),
          );
        },
      ),
    );
  }
}
