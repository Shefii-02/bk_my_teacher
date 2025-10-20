// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/api_service.dart';
//
// final apiServiceProvider = Provider((ref) => ApiService());
// final carouselDataProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, apiType) async {
//   final api = ref.read(apiServiceProvider);
//   final data = await api.fetchTopBanners();
//
//   return List<Map<String, dynamic>>.from(data);
// });
