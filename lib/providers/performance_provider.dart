import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/performance_summary.dart';
import '../services/api_service.dart';

final performanceProvider = FutureProvider.family<TeacherPerformanceModel?, String>((ref, filter) async {
  return await ApiService().fetchTeacherPerformance(filter);
});
