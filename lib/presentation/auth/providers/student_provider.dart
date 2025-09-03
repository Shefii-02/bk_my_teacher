// lib/providers/teacher_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/student_api_service.dart';

final teacherApiProvider = Provider<StudentApiService>((ref) {
  return StudentApiService();
});

final studentSignupProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(teacherApiProvider);

  return api.registerStudent(
    studentId: data["student_id"],
    studentName: data["student_name"],
    parentName: data["parent_name"],
    email: data["email"],
    address: data["address"],
    city: data["city"],
    postalCode: data["postalCode"],
    district: data["district"],
    state: data["state"],
    country: data["country"],
    selectedDays: List<String>.from(data["selectedDays"]),
    selectedHours: List<String>.from(data["selectedHours"]),
    seekingGrades: List<String>.from(data["seekingGrades"] ?? []),
    seekingSubjects: List<String>.from(data["seekingSubjects"] ?? []),
    interest: data["interest"],
    avatar: data["avatar"] as File?,
  );
});
