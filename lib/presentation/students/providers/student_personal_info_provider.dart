import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/student_api_service.dart';
import '../../../services/teacher_api_service.dart';
import 'package:file_picker/file_picker.dart';

final teacherApiProvider = Provider<StudentApiService>((ref) {
  return StudentApiService();
});

final studentPersonalInfoProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(teacherApiProvider);
  return api.updateStudentPersonal(
    name: data["name"],
    email: data["email"],
    address: data["address"],
    city: data["city"],
    postalCode: data["postalCode"],
    district: data["district"],
    state: data["state"],
    country: data["country"],
    avatar: data["avatar"] as PlatformFile?,
  );
});
