import 'package:BookMyTeacher/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/student_model.dart';
final accountApiServiceProvider = Provider((ref) => ApiService());

final studentProfileProvider = FutureProvider<StudentModel>((ref) async {
  final api = ref.watch(accountApiServiceProvider);
  return api.profileUserData();
});
