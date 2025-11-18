import 'dart:convert';
import 'package:BookMyTeacher/model/time_card_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/teacher_api_service.dart';

final spendTimeCardProvider =
FutureProvider<List<TimeCardModel>>((ref) async {
  return await TeacherApiService().fetchSpendTime();
});
