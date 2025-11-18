import 'package:BookMyTeacher/services/teacher_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final achievementsProvider = FutureProvider((ref) async {
  return await TeacherApiService().fetchAchievements();
});
