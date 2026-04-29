// ─── course_purchase_api_service.dart ────────────────────────────────────────
// Handles all HTTP requests for the Course Purchase feature.

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../core/constants/endpoints.dart';
import 'course_purchase_model.dart';

class CoursePurchaseApiService {
  final Dio _dio;

  CoursePurchaseApiService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.base, // ← replace
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        // 'Authorization': 'Bearer $token', // add token interceptor
      },
    ),
  );

  Future<void> _loadAuth() async {

    final box =
    await Hive.openBox('app_storage');

    final token =
    box.get("auth_token");

    if(token!=null){

      _dio.options.headers[
      "Authorization"
      ]="Bearer $token";

    }

  }

  // GET course/{id}/purchase-info
  Future<CoursePurchaseInfoResponse> getPurchaseInfo(int courseId) async {
    await _loadAuth();
    final res = await _dio.get('/course/$courseId/purchase-info');
    return CoursePurchaseInfoResponse.fromJson(res.data);
  }

  // POST coupon/validate
  Future<CouponValidateResponse> validateCoupon({
    required int courseId,
    required String couponCode,
  }) async {
    await _loadAuth();
    final res = await _dio.post('/coupon/validate', data: {
      'course_id': courseId,
      'coupon_code': couponCode,
    });
    return CouponValidateResponse.fromJson(res.data);
  }

  // POST order/create
  Future<OrderCreateResponse> createOrder(OrderCreateRequest request) async {
    await _loadAuth();
    final res = await _dio.post('/order/create', data: request.toJson());
    return OrderCreateResponse.fromJson(res.data);
  }
}