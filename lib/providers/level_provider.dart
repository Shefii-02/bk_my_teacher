import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/teacher_api_service.dart';

final currentLevelProvider = FutureProvider((ref) async {
  return await TeacherApiService().fetchCurrentLevel();
});
