// lib/providers/teacher_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/teacher_api_service.dart';

final teacherApiProvider = Provider<TeacherApiService>((ref) {
  return TeacherApiService();
});

final teacherSignupProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(teacherApiProvider);
  return api.registerTeacher(
    name: data["name"],
    email: data["email"],
    address: data["address"],
    city: data["city"],
    postalCode: data["postalCode"],
    district: data["district"],
    state: data["state"],
    country: data["country"],
    profession: data["profession"],
    readyToWork: data["readyToWork"],
    selectedDays: List<String>.from(data["selectedDays"]),
    selectedHours: List<String>.from(data["selectedHours"]),
    teachingGrades: List<String>.from(data["teachingGrades"]),
    teachingSubjects: List<String>.from(data["teachingSubjects"]),
    experience: data["experience"],
    cvFile: data["cvFile"] as File?,
  );
});
