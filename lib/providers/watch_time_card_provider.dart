import 'package:BookMyTeacher/model/time_card_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/teacher_api_service.dart';

final watchTimeCardProvider = FutureProvider<List<TimeCardModel>>((
  ref,
) async {
  return await TeacherApiService().fetchWatchTime();
});
