import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../core/constants/endpoints.dart';
import '../model/user_model.dart';

class UserRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  //
  // // 🔹 Add auth token to header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }


  Future<void> _loadAuth() async {
    final box = await Hive.openBox('app_storage');
    final token = box.get('auth_token') ?? '';

    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }




  Future<UserModel> profileUserData() async {
    // final box = await Hive.openBox('app_storage');
    // final token = box.get('auth_token') ?? '';
    // if (token.isNotEmpty) setAuthToken(token);
    // print(token);
    await _loadAuth();
    final response = await _dio.post("/user-data-retrieve");
    final data = response.data['user'];
    return UserModel.fromJson(data);
  }


  // Future<UserModel> updateUser(Map<String, dynamic> payload) async {
  //   final response = await _dio.post("/user/update", data: payload);
  //   if (response.statusCode == 200) {
  //     return UserModel.fromJson(response.data["data"]);
  //   } else {
  //     throw Exception("Failed to update user");
  //   }
  // }
}
