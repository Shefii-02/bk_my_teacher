// ─── course_purchase_model.dart ──────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Purchase Info Response
// ─────────────────────────────────────────────────────────────────────────────

class CoursePurchaseInfoResponse {
  final bool status;
  final String message;
  final CoursePurchaseInfo? data;

  CoursePurchaseInfoResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CoursePurchaseInfoResponse.fromJson(Map<String, dynamic> json) =>
      CoursePurchaseInfoResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null
            ? CoursePurchaseInfo.fromJson(json['data'])
            : null,
      );
}

class CoursePurchaseInfo {
  final PurchaseCourseDetail course;
  final CoursePricing pricing;
  final bool couponAllowed;
  final bool instalmentAllowed;
  final List<AvailableCoupon> coupons;
  final List<InstalmentDetail> instalments;
  final List<PaymentMethod> paymentMethods;

  CoursePurchaseInfo({
    required this.course,
    required this.pricing,
    required this.couponAllowed,
    required this.instalmentAllowed,
    required this.coupons,
    required this.instalments,
    required this.paymentMethods,
  });

  factory CoursePurchaseInfo.fromJson(Map<String, dynamic> json) =>
      CoursePurchaseInfo(
        course: PurchaseCourseDetail.fromJson(json['course'] ?? {}),
        pricing: CoursePricing.fromJson(json['pricing'] ?? {}),
        couponAllowed: json['coupon_allowed'] ?? false,
        instalmentAllowed: json['instalment_allowed'] ?? false,
        coupons: (json['coupons'] as List<dynamic>? ?? [])
            .map((e) => AvailableCoupon.fromJson(e))
            .toList(),
        instalments: (json['instalments'] as List<dynamic>? ?? [])
            .map((e) => InstalmentDetail.fromJson(e))
            .toList(),
        paymentMethods: (json['payment_methods'] as List<dynamic>? ?? [])
            .map((e) => PaymentMethod.fromJson(e))
            .toList(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Course Detail (lightweight for purchase page)
// ─────────────────────────────────────────────────────────────────────────────

class PurchaseCourseDetail {
  final int id;
  final String title;
  final String? thumbnailUrl;
  final String? typeClass;
  final String? level;
  final String? duration;
  final String? mode;
  final int studentCount;

  PurchaseCourseDetail({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    this.typeClass,
    this.level,
    this.duration,
    this.mode,
    this.studentCount = 0,
  });

  factory PurchaseCourseDetail.fromJson(Map<String, dynamic> json) =>
      PurchaseCourseDetail(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        thumbnailUrl: json['thumbnail_url'],
        typeClass: json['type_class'],
        level: json['level'],
        duration: json['duration'],
        mode: json['mode'],
        studentCount: json['student_count'] ?? 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Pricing
// ─────────────────────────────────────────────────────────────────────────────

class CoursePricing {
  final double courseFee;
  final double gstRate;
  final double gstAmount;
  final double originalPrice;
  final double totalAmount;
  final String currency;

  CoursePricing({
    required this.courseFee,
    required this.gstRate,
    required this.gstAmount,
    required this.originalPrice,
    required this.totalAmount,
    this.currency = 'INR',
  });

  factory CoursePricing.fromJson(Map<String, dynamic> json) => CoursePricing(
    courseFee: (json['course_fee'] ?? 0).toDouble(),
    gstRate: (json['gst_rate'] ?? 18).toDouble(),
    gstAmount: (json['gst_amount'] ?? 0).toDouble(),
    originalPrice: (json['original_price'] ?? 0).toDouble(),
    totalAmount: (json['total_amount'] ?? 0).toDouble(),
    currency: json['currency'] ?? 'INR',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupon
// ─────────────────────────────────────────────────────────────────────────────

class AvailableCoupon {
  final int id;
  final String code;
  final String? description;
  final String type; // percent | flat
  final double value;
  final double? maxDiscount;
  final double discountAmount;
  final String? expiresAt;

  AvailableCoupon({
    required this.id,
    required this.code,
    this.description,
    required this.type,
    required this.value,
    this.maxDiscount,
    required this.discountAmount,
    this.expiresAt,
  });

  factory AvailableCoupon.fromJson(Map<String, dynamic> json) =>
      AvailableCoupon(
        id: json['id'] ?? 0,
        code: json['code'] ?? '',
        description: json['description'],
        type: json['type'] ?? 'flat',
        value: (json['value'] ?? 0).toDouble(),
        maxDiscount: json['max_discount'] != null
            ? (json['max_discount']).toDouble()
            : null,
        discountAmount: (json['discount_amount'] ?? 0).toDouble(),
        expiresAt: json['expires_at'],
      );

  String get displayLabel {
    if (type == 'percent') {
      final max = maxDiscount != null
          ? ' (max ₹${maxDiscount!.toStringAsFixed(0)})'
          : '';
      return '${value.toStringAsFixed(0)}% off$max';
    }
    return 'Flat ₹${value.toStringAsFixed(0)} off';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupon Validate Response
// ─────────────────────────────────────────────────────────────────────────────

class CouponValidateResponse {
  final bool status;
  final String message;
  final CouponValidateData? data;

  CouponValidateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CouponValidateResponse.fromJson(Map<String, dynamic> json) =>
      CouponValidateResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null
            ? CouponValidateData.fromJson(json['data'])
            : null,
      );
}

class CouponValidateData {
  final int couponId;
  final String code;
  final String? description;
  final String type;
  final double value;
  final double discountAmount;
  final double originalAmount;
  final double finalAmount;

  CouponValidateData({
    required this.couponId,
    required this.code,
    this.description,
    required this.type,
    required this.value,
    required this.discountAmount,
    required this.originalAmount,
    required this.finalAmount,
  });

  factory CouponValidateData.fromJson(Map<String, dynamic> json) =>
      CouponValidateData(
        couponId: json['coupon_id'] ?? 0,
        code: json['code'] ?? '',
        description: json['description'],
        type: json['type'] ?? 'flat',
        value: (json['value'] ?? 0).toDouble(),
        discountAmount: (json['discount_amount'] ?? 0).toDouble(),
        originalAmount: (json['original_amount'] ?? 0).toDouble(),
        finalAmount: (json['final_amount'] ?? 0).toDouble(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Instalment
// ─────────────────────────────────────────────────────────────────────────────

class InstalmentDetail {
  final int instalmentNumber;
  final String label;
  final String dueDate;
  final String dueDateLabel;
  final double amount;
  final int percentage;
  final String status; // pay_now | pay_later

  InstalmentDetail({
    required this.instalmentNumber,
    required this.label,
    required this.dueDate,
    required this.dueDateLabel,
    required this.amount,
    required this.percentage,
    required this.status,
  });

  bool get isPayNow => status == 'pay_now';

  factory InstalmentDetail.fromJson(Map<String, dynamic> json) =>
      InstalmentDetail(
        instalmentNumber: json['instalment_number'] ?? 1,
        label: json['label'] ?? '',
        dueDate: json['due_date'] ?? '',
        dueDateLabel: json['due_date_label'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        percentage: json['percentage'] ?? 50,
        status: json['status'] ?? 'pay_now',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Method
// ─────────────────────────────────────────────────────────────────────────────

class PaymentMethod {
  final String key; // upi | phonepe | razorpay | pay_later
  final String label;
  final String description;
  final String icon;
  final String? upiId;
  final String? razorpayKeyId;

  PaymentMethod({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    this.upiId,
    this.razorpayKeyId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    key: json['key'] ?? '',
    label: json['label'] ?? '',
    description: json['description'] ?? '',
    icon: json['icon'] ?? '',
    upiId: json['upi_id'],
    razorpayKeyId: json['key_id'],
  );

  bool get isPayLater => key == 'pay_later';
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Create Request
// ─────────────────────────────────────────────────────────────────────────────

class OrderCreateRequest {
  final int courseId;
  final int? couponId;
  final String paymentMethod;
  final String paymentPlan; // full | instalment
  final double courseFee;
  final double gstAmount;
  final double discountAmount;
  final double totalAmount;
  final double payNowAmount;

  OrderCreateRequest({
    required this.courseId,
    this.couponId,
    required this.paymentMethod,
    required this.paymentPlan,
    required this.courseFee,
    required this.gstAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.payNowAmount,
  });

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    if (couponId != null) 'coupon_id': couponId,
    'payment_method': paymentMethod,
    'payment_plan': paymentPlan,
    'course_fee': courseFee,
    'gst_amount': gstAmount,
    'discount_amount': discountAmount,
    'total_amount': totalAmount,
    'pay_now_amount': payNowAmount,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Create Response
// ─────────────────────────────────────────────────────────────────────────────

class OrderCreateResponse {
  final bool status;
  final String message;
  final OrderCreatedData? data;

  OrderCreateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) =>
      OrderCreateResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null
            ? OrderCreatedData.fromJson(json['data'])
            : null,
      );
}

class OrderCreatedData {
  final int orderId;
  final String orderNumber;
  final String paymentPlan;
  final double payNow;
  final double total;
  final PaymentGatewayData payment;

  OrderCreatedData({
    required this.orderId,
    required this.orderNumber,
    required this.paymentPlan,
    required this.payNow,
    required this.total,
    required this.payment,
  });

  factory OrderCreatedData.fromJson(Map<String, dynamic> json) =>
      OrderCreatedData(
        orderId: json['order_id'] ?? 0,
        orderNumber: json['order_number'] ?? '',
        paymentPlan: json['payment_plan'] ?? 'full',
        payNow: (json['pay_now'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        payment: PaymentGatewayData.fromJson(json['payment'] ?? {}),
      );
}

class PaymentGatewayData {
  final String method;
  final double amount;
  // UPI
  final String? upiId;
  final String? upiLink;
  // PhonePe
  final String? transactionId;
  final String? payload;
  final String? checksum;
  // Razorpay
  final String? razorpayOrderId;
  final String? razorpayKey;
  final String? currency;
  final String? name;
  final Map<String, dynamic>? prefill;
  // Pay later
  final String? message;
  final String? dueDate;

  PaymentGatewayData({
    required this.method,
    required this.amount,
    this.upiId,
    this.upiLink,
    this.transactionId,
    this.payload,
    this.checksum,
    this.razorpayOrderId,
    this.razorpayKey,
    this.currency,
    this.name,
    this.prefill,
    this.message,
    this.dueDate,
  });

  factory PaymentGatewayData.fromJson(Map<String, dynamic> json) =>
      PaymentGatewayData(
        method: json['method'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        upiId: json['upi_id'],
        upiLink: json['upi_link'],
        transactionId: json['transaction_id'],
        payload: json['payload'],
        checksum: json['checksum'],
        razorpayOrderId: json['razorpay_order_id'],
        razorpayKey: json['razorpay_key'],
        currency: json['currency'],
        name: json['name'],
        prefill: json['prefill'] != null
            ? Map<String, dynamic>.from(json['prefill'])
            : null,
        message: json['message'],
        dueDate: json['due_date'],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Local calculation state (used in controller)
// ─────────────────────────────────────────────────────────────────────────────

class PriceSummary {
  final double courseFee;
  final double gstRate;
  final double gstAmount;
  final double discountAmount;
  final double totalAmount;
  final double payNowAmount;
  final int? appliedCouponId;
  final String? appliedCouponCode;

  PriceSummary({
    required this.courseFee,
    required this.gstRate,
    required this.gstAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.payNowAmount,
    this.appliedCouponId,
    this.appliedCouponCode,
  });

  /// [clearCoupon] must be true to explicitly null out the applied coupon fields.
  /// Using `??` alone cannot distinguish "not passed" from "intentionally null".
  PriceSummary copyWith({
    double? discountAmount,
    int? appliedCouponId,
    String? appliedCouponCode,
    String? paymentPlan,
    bool clearCoupon = false,
  }) {
    final disc = discountAmount ?? this.discountAmount;
    final total =
    (courseFee + gstAmount - disc).clamp(0.0, double.infinity);
    return PriceSummary(
      courseFee: courseFee,
      gstRate: gstRate,
      gstAmount: gstAmount,
      discountAmount: disc,
      totalAmount: total,
      payNowAmount: paymentPlan == 'instalment'
          ? (total / 2).ceilToDouble()
          : total,
      appliedCouponId: clearCoupon ? null : (appliedCouponId ?? this.appliedCouponId),
      appliedCouponCode:
      clearCoupon ? null : (appliedCouponCode ?? this.appliedCouponCode),
    );
  }
}