import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/constants/endpoints.dart';
import '../model/webinar.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
});

/// Fetch webinars list by accType (teacher/student/guest)
final webinarListProvider = FutureProvider.family<List<Webinar>, String>((
  ref,
  accType,
) async {
  final token = await LaunchStatusService.getAuthToken();
  if (token != null) {
    ref.read(dioProvider).options.headers['Authorization'] = 'Bearer $token';
  }
  final dio = ref.read(dioProvider);
  try {
    print(dio.options.headers);

    final response = await dio.post(
      Endpoints.getWebinars,
      data: {'acc_type': accType},
    );

    // print(response);

    if (response.statusCode == 200 && response.data['status'] == true) {
      final List list = response.data['data'];
      return list.map((e) => Webinar.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message'] ?? "Failed to fetch webinars");
    }
  } on DioException catch (e) {
    print(e.message);
    throw Exception("Network error: ${e.message}");
  } catch (e) {
    throw Exception("Unexpected error: $e");
  }
});

/// Single webinar details
final webinarDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
      final dio = ref.read(dioProvider);
      final response = await dio.post("/webinars/$id");
      return response.data['data'];
    });

/// Webinar registration
final webinarRegisterProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {

      final token = await LaunchStatusService.getAuthToken();
      if (token != null) {
        ref.read(dioProvider).options.headers['Authorization'] =
            'Bearer $token';
      }
      final dio = ref.read(dioProvider);
      print(dio.options.headers);
      final response = await dio.post("/webinars/$id/register");
      return response.data;
    });

/// Webinar join
final webinarJoinProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  id,
) async {
  final token = await LaunchStatusService.getAuthToken();
  if (token != null) {
    ref.read(dioProvider).options.headers['Authorization'] = 'Bearer $token';
  }
  final dio = ref.read(dioProvider);
  final response = await dio.post("/webinars/$id/join");
  return response.data;
});
