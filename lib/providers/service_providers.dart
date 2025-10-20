import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// --- Provider for API service ---
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// --- Fetch all search data (teachers, subjects, grades, boards) ---
final searchDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.fetchAllSearchData();
});

// --- Selected filters state ---
final selectedFiltersProvider = StateProvider<Map<String, List<int>>>((ref) {
  return {
    'teachers': [],
    'subjects': [],
    'grades': [],
    'boards': [],
  };
});


final carouselDataProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, apiType) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.fetchTopBanners();

  return List<Map<String, dynamic>>.from(data);
});


final gradesProvider = FutureProvider<List<DropdownItem>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchDropdownData('grades');
});

final boardsProvider = FutureProvider<List<DropdownItem>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchDropdownData('boards');
});

final subjectsProvider = FutureProvider<List<DropdownItem>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchDropdownData('subjects');
});
