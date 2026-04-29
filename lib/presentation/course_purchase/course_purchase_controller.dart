// ─── course_purchase_controller.dart ─────────────────────────────────────────
// Handles: load purchase info, coupon apply/remove, price calc, order create

import 'package:flutter/material.dart';
import 'course_purchase_api_service.dart';
import 'course_purchase_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Controller (ChangeNotifier — works with Provider or setState)
// ─────────────────────────────────────────────────────────────────────────────

class CoursePurchaseController extends ChangeNotifier {
  final int courseId;
  final CoursePurchaseApiService _api;

  CoursePurchaseController({required this.courseId})
      : _api = CoursePurchaseApiService();

  // ── state ──────────────────────────────────────────────────────────────────
  bool isLoading = false;
  bool isCouponLoading = false;
  bool isOrderLoading = false;
  String? errorMsg;
  String? couponError;
  String? couponSuccess;

  CoursePurchaseInfo? purchaseInfo;
  PriceSummary? priceSummary;

  // form state
  String paymentPlan = 'full'; // full | instalment
  String paymentMethod = ''; // first available method
  final TextEditingController couponController = TextEditingController();

  // applied coupon
  int? appliedCouponId;
  String? appliedCouponCode;
  double discountAmount = 0;

  // ── init ───────────────────────────────────────────────────────────────────
  Future<void> loadPurchaseInfo() async {
    isLoading = true;
    errorMsg = null;
    notifyListeners();

    try {
      final res = await _api.getPurchaseInfo(courseId);
      if (res.status && res.data != null) {
        purchaseInfo = res.data;
        _initPriceSummary();
        // set default payment method to first non-pay_later method
        final mainMethods =
        purchaseInfo!.paymentMethods.where((m) => !m.isPayLater).toList();
        if (mainMethods.isNotEmpty) {
          paymentMethod = mainMethods.first.key;
        } else if (purchaseInfo!.paymentMethods.isNotEmpty) {
          paymentMethod = purchaseInfo!.paymentMethods.first.key;
        }
      } else {
        errorMsg = res.message;
      }
    } catch (e) {
      errorMsg = 'Failed to load purchase info. Please try again.';
      debugPrint('loadPurchaseInfo error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _initPriceSummary() {
    if (purchaseInfo == null) return;
    final p = purchaseInfo!.pricing;
    priceSummary = PriceSummary(
      courseFee: p.courseFee,
      gstRate: p.gstRate,
      gstAmount: p.gstAmount,
      discountAmount: 0,
      totalAmount: p.totalAmount,
      payNowAmount: p.totalAmount,
    );
  }

  // ── payment plan toggle ────────────────────────────────────────────────────
  void setPaymentPlan(String plan) {
    paymentPlan = plan;
    _recalculate();
    notifyListeners();
  }

  // ── payment method select ──────────────────────────────────────────────────
  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  // ── coupon: select from list ───────────────────────────────────────────────
  void selectAvailableCoupon(AvailableCoupon coupon) {
    couponController.text = coupon.code;
    couponError = null;
    _applyCouponLocally(
      couponId: coupon.id,
      code: coupon.code,
      discountAmt: coupon.discountAmount,
    );
  }

  // ── coupon: manual apply (hits API) ───────────────────────────────────────
  Future<void> applyManualCoupon() async {
    final code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    isCouponLoading = true;
    couponError = null;
    couponSuccess = null;
    notifyListeners();

    try {
      final res = await _api.validateCoupon(
        courseId: courseId,
        couponCode: code,
      );
      if (res.status && res.data != null) {
        _applyCouponLocally(
          couponId: res.data!.couponId,
          code: res.data!.code,
          discountAmt: res.data!.discountAmount,
        );
        couponSuccess =
        '${res.data!.code} applied — ₹${res.data!.discountAmount.toStringAsFixed(0)} off!';
      } else {
        couponError = res.message;
      }
    } catch (e) {
      couponError = 'Failed to apply coupon. Please try again.';
      debugPrint('applyManualCoupon error: $e');
    } finally {
      isCouponLoading = false;
      notifyListeners();
    }
  }

  void _applyCouponLocally({
    required int couponId,
    required String code,
    required double discountAmt,
  }) {
    appliedCouponId = couponId;
    appliedCouponCode = code;
    discountAmount = discountAmt;
    couponSuccess =
    '$code applied — ₹${discountAmt.toStringAsFixed(0)} off!';
    _recalculate();
    notifyListeners();
  }

  // ── coupon: remove ─────────────────────────────────────────────────────────
  void removeCoupon() {
    appliedCouponId = null;
    appliedCouponCode = null;
    discountAmount = 0;
    couponController.clear();
    couponSuccess = null;
    couponError = null;
    _recalculate();
    notifyListeners();
  }

  // ── recalculate prices ─────────────────────────────────────────────────────
  void _recalculate() {
    if (priceSummary == null) return;
    priceSummary = priceSummary!.copyWith(
      discountAmount: discountAmount,
      // Pass sentinel values to allow nulling out applied coupon
      appliedCouponId: appliedCouponId,
      appliedCouponCode: appliedCouponCode,
      paymentPlan: paymentPlan,
      clearCoupon: appliedCouponId == null,
    );
  }

  // ── computed getters ───────────────────────────────────────────────────────
  double get courseFee => priceSummary?.courseFee ?? 0;
  double get gstAmount => priceSummary?.gstAmount ?? 0;
  double get gstRate => priceSummary?.gstRate ?? 18;
  double get discount => priceSummary?.discountAmount ?? 0;
  double get totalAmount => priceSummary?.totalAmount ?? 0;
  double get payNowAmount => priceSummary?.payNowAmount ?? 0;
  double get originalTotal => courseFee + gstAmount;
  bool get hasCouponApplied => appliedCouponId != null;

  // instalment computed
  double get instalment1Amount => (totalAmount / 2).ceilToDouble();
  double get instalment2Amount => totalAmount - instalment1Amount;

  String get instalment2DueDate {
    if (purchaseInfo?.instalments.length == 2) {
      return purchaseInfo!.instalments[1].dueDateLabel;
    }
    return '';
  }

  // CTA button label
  String get ctaLabel {
    final amt =
    paymentPlan == 'instalment' ? instalment1Amount : payNowAmount;
    final fmtAmt = '₹${amt.toStringAsFixed(0)}';
    if (paymentMethod == 'pay_later') return 'Register — Pay Later';
    if (paymentPlan == 'instalment') return 'Pay 1st Instalment — $fmtAmt';
    return 'Buy Now — $fmtAmt';
  }

  // ── create order ───────────────────────────────────────────────────────────
  Future<OrderCreatedData?> createOrder() async {
    if (paymentMethod.isEmpty) return null;

    isOrderLoading = true;
    errorMsg = null;
    notifyListeners();

    try {
      final request = OrderCreateRequest(
        courseId: courseId,
        couponId: appliedCouponId,
        paymentMethod: paymentMethod,
        paymentPlan: paymentPlan,
        courseFee: courseFee,
        gstAmount: gstAmount,
        discountAmount: discount,
        totalAmount: totalAmount,
        payNowAmount: paymentPlan == 'instalment'
            ? instalment1Amount
            : payNowAmount,
      );

      final res = await _api.createOrder(request);
      if (res.status && res.data != null) {
        return res.data;
      } else {
        errorMsg = res.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      errorMsg = 'Order creation failed. Please try again.';
      debugPrint('createOrder error: $e');
      notifyListeners();
      return null;
    } finally {
      isOrderLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}