import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/teacher_api_service.dart';
import 'package:file_picker/file_picker.dart';

final teacherApiProvider = Provider<TeacherApiService>((ref) {
  return TeacherApiService();
});

final teacherPersonalInfoProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(teacherApiProvider);
  return api.updateTeacherPersonal(
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



final teacherTeachingDetailsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(teacherApiProvider);
  return api.updateTeachingDetailsTeacher(
    interest: data["interest"],
    profession: data["profession"],
    readyToWork: data["readyToWork"],
    selectedDays: List<String>.from(data["selectedDays"]),
    selectedHours: List<String>.from(data["selectedHours"]),
    teachingGrades: List<String>.from(data["teachingGrades"]),
    teachingSubjects: List<String>.from(data["teachingSubjects"]),
    offlineExp: data["offline_exp"],
    onlineExp: data["online_exp"],
    homeExp: data["home_exp"]
  );
});

final teacherCvProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(teacherApiProvider);
  return api.updateCvTeacher(
    cvFile: data["cvFile"] as PlatformFile?,
  );
});