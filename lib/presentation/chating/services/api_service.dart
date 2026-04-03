import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:BookMyTeacher/core/constants/chat_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    /// 🔐 Add token automatically
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final box = await Hive.openBox('app_storage');
          final token = box.get('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (e, handler) {
          print("❌ API Error: ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  /// 📥 GET CHAT LIST
  Future<List> getChats(int userId) async {
    try {

      final res = await dio.get("/chat");

      return res.data;
    } catch (e) {
      print("❌ getChats error: $e");
      return [];
    }
  }

  /// 📥 GET MESSAGES (with pagination support)
  Future<List> getMessages(int convId, {int page = 1}) async {
    try {
      final res = await dio.get(
        "/messages/$convId",
        queryParameters: {"page": page},
      );

      return res.data;
    } catch (e) {
      print("❌ getMessages error: $e");
      return [];
    }
  }

  /// 📤 UPLOAD FILE
  Future<String?> uploadFile(String path) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path),
      });

      final res = await dio.post("/upload", data: formData);

      return res.data['url'];
    } catch (e) {
      print("❌ upload error: $e");
      return null;
    }
  }
}