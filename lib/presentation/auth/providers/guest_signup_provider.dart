// lib/providers/teacher_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/guest_api_service.dart';
import '../../../services/student_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';


final guestApiProvider = Provider<GuestApiService>((ref) {
  return GuestApiService();
});

final guestSignupProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(guestApiProvider);

  final fullName = (data["full_name"] ?? "").toString();
  final email = (data["email"] ?? "").toString();
  final avatar = data["avatar"] as PlatformFile?;

  return api.registerGuest(
    fullName: fullName,
    email: email,
    avatar: avatar,
  );
});
