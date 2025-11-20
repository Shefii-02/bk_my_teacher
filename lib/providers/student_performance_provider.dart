import 'package:BookMyTeacher/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/student_performance.dart';

final studentPerformanceProvider = FutureProvider<StudentPerformance>((ref) async {
  return await ApiService().getStudentPerformance();
});
