import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Returns Map containing file info for mobile or bytes for web
  /// Mobile: {"file": File}
  /// Web: {"bytes": Uint8List, "name": String}
  static Future<Map<String, dynamic>?> pickAvatar(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return null;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return {"bytes": bytes, "name": image.name};
      } else {
        return {"file": File(image.path)};
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
      return null;
    }
  }
}
