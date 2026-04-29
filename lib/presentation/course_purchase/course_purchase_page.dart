// ─── course_purchase_page.dart ────────────────────────────────────────────────
// Full Course Purchase Page
// Sections: Course Info | Coupon | Pricing | Payment Plan | Payment Method | CTA

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'course_purchase_controller.dart';
import 'course_purchase_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1D9E75);
const _kPrimaryDk = Color(0xFF085041);
const _kPrimaryLt = Color(0xFFE1F5EE);
const _kPrimaryMd = Color(0xFF9FE1CB);
const _kAmber     = Color(0xFFB85C00);
const _kAmberLt   = Color(0xFFFFF3E0);
const _kRed       = Color(0xFFE53935);
const _kRedLt     = Color(0xFFFFEBEE); // ← single definition (duplicate removed)
const _kBorder    = Color(0xFFEEEEEE);
const _kSurface   = Color(0xFFF8F8FC);
const _kText      = Color(0xFF1A1A2E);
const _kMuted     = Color(0xFF9E9E9E);
const _kPurple    = Color(0xFF534AB7);
const _kPurpleLt  = Color(0xFFEEEDFE);

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class CoursePurchasePage extends StatefulWidget {
  final int courseId;
  const CoursePurchasePage({super.key, required this.courseId});

  @override
  State<CoursePurchasePage> createState() => _CoursePurchasePageState();
}

class _CoursePurchasePageState extends State<CoursePurchasePage> {
  late final CoursePurchaseController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CoursePurchaseController(courseId: widget.courseId);
    _ctrl.addListener(_onUpdate);
    _ctrl.loadPurchaseInfo();
  }

  void _onUpdate() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  // ── buy now ────────────────────────────────────────────────────────────────
  Future<void> _handleBuyNow() async {
    final data = await _ctrl.createOrder();
    if (data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_ctrl.errorMsg ?? 'Order failed'),
            backgroundColor: _kRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    await _handlePaymentRedirect(data.payment);
  }

  Future<void> _handlePaymentRedirect(PaymentGatewayData payment) async {
    switch (payment.method) {
      case 'upi':
        await _launchUpi(payment);
        break;
      case 'phonepe':
        await _launchPhonePe(payment);
        break;
      case 'razorpay':
        await _launchRazorpay(payment);
        break;
      case 'pay_later':
        _showPayLaterSuccess(payment);
        break;
    }
  }

  Future<void> _launchUpi(PaymentGatewayData payment) async {
    if (payment.upiLink == null) return;
    final uri = Uri.parse(payment.upiLink!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showSnack('No UPI app found. UPI ID: ${payment.upiId}');
      }
    }
  }

  Future<void> _launchPhonePe(PaymentGatewayData payment) async {
    // PhonePe S2S — in production open a WebView or use their SDK
    // with payment.payload and payment.checksum
    if (mounted) {
      _showSnack('Redirecting to PhonePe...');
      // TODO: open PhonePe WebView or SDK with payload/checksum
    }
  }

  Future<void> _launchRazorpay(PaymentGatewayData payment) async {
    // Use razorpay_flutter package:
    // var options = {
    //   'key': payment.razorpayKey,
    //   'amount': (payment.amount * 100).toInt(),
    //   'currency': payment.currency ?? 'INR',
    //   'name': payment.name,
    //   'order_id': payment.razorpayOrderId,
    //   'prefill': payment.prefill,
    // };
    // _razorpay.open(options);
    if (mounted) _showSnack('Opening Razorpay...');
  }

  void _showPayLaterSuccess(PaymentGatewayData payment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: _kPrimary, size: 24),
            SizedBox(width: 8),
            Text('Registered!',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(payment.message ?? 'You are registered. Pay when ready.'),
            if (payment.dueDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Due by: ${payment.dueDate}',
                style: const TextStyle(
                    fontSize: 12,
                    color: _kAmber,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: _kPrimary)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.pop(context)),
          Expanded(child: _body()),
          if (_ctrl.purchaseInfo != null)
            _BottomCta(ctrl: _ctrl, onTap: _handleBuyNow),
        ],
      ),
    );
  }

  Widget _body() {
    if (_ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ctrl.errorMsg != null && _ctrl.purchaseInfo == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _kRed),
            const SizedBox(height: 12),
            Text(_ctrl.errorMsg!,
                style: const TextStyle(color: _kMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _ctrl.loadPurchaseInfo,
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final info = _ctrl.purchaseInfo!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        // 1. Course Info
        _CourseInfoCard(course: info.course),
        const SizedBox(height: 12),

        // 2. Coupon (only if allowed)
        if (info.couponAllowed) ...[
          _CouponCard(ctrl: _ctrl, coupons: info.coupons),
          const SizedBox(height: 12),
        ],

        // 3. Pricing
        _PricingCard(ctrl: _ctrl),
        const SizedBox(height: 12),

        // 4. Payment Plan
        if (info.instalmentAllowed) ...[
          _PaymentPlanCard(ctrl: _ctrl),
          const SizedBox(height: 12),
        ],

        // 5. Payment Methods
        _PaymentMethodCard(ctrl: _ctrl, methods: info.paymentMethods),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 10, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, _kPrimaryDk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // FIX: withOpacity deprecated → use Color.fromRGBO
                color: Color.fromRGBO(255, 255, 255, 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Course Purchase',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('Review & complete your enrollment',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Course Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _CourseInfoCard extends StatelessWidget {
  final PurchaseCourseDetail course;
  const _CourseInfoCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: course.thumbnailUrl != null
                ? Image.network(
              course.thumbnailUrl!,
              width: double.infinity,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackThumb(),
            )
                : _fallbackThumb(),
          ),
          const SizedBox(height: 12),
          Text(
            course.title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: _kText),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (course.typeClass != null)
                _MetaChip(
                    label: course.typeClass!.toUpperCase(),
                    icon: Icons.sensors_rounded,
                    color: _kPrimary),
              if (course.duration != null)
                _MetaChip(
                    label: course.duration!,
                    icon: Icons.timer_outlined),
              if (course.level != null)
                _MetaChip(
                    label: _cap(course.level!),
                    icon: Icons.grade_outlined),
              if (course.mode != null)
                _MetaChip(
                    label: _cap(course.mode!),
                    icon: Icons.live_tv_outlined),
              _MetaChip(
                  label: '${course.studentCount} students',
                  icon: Icons.people_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackThumb() => Container(
    height: 110,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_kPrimary, _kPrimaryDk],
      ),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    child: const Center(
      child: Icon(Icons.school_rounded, size: 40, color: Colors.white54),
    ),
  );

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupon Card
// ─────────────────────────────────────────────────────────────────────────────

class _CouponCard extends StatefulWidget {
  final CoursePurchaseController ctrl;
  final List<AvailableCoupon> coupons;
  const _CouponCard({required this.ctrl, required this.coupons});

  @override
  State<_CouponCard> createState() => _CouponCardState();
}

// FIX: converted to StatefulWidget so we can listen to couponController
// and rebuild the suffix clear-button correctly.
class _CouponCardState extends State<_CouponCard> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.couponController.addListener(_onTextChange);
  }

  void _onTextChange() => setState(() {});

  @override
  void dispose() {
    widget.ctrl.couponController.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl    = widget.ctrl;
    final coupons = widget.coupons;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Row(
            children: [
              Text('🎟️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Apply Coupon',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kText)),
            ],
          ),
          const SizedBox(height: 14),

          // Manual entry row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl.couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: const TextStyle(fontSize: 13, color: _kMuted),
                    filled: true,
                    fillColor: _kSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kPrimary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    suffixIcon: ctrl.couponController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 16, color: _kMuted),
                      onPressed: ctrl.couponController.clear,
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: ctrl.isCouponLoading ? null : ctrl.applyManualCoupon,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: ctrl.isCouponLoading ? _kMuted : _kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: ctrl.isCouponLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Apply',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),

          // Error
          if (ctrl.couponError != null) ...[
            const SizedBox(height: 8),
            _AlertBanner(message: ctrl.couponError!, isError: true),
          ],

          // Applied banner
          if (ctrl.hasCouponApplied) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kPrimaryLt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kPrimaryMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: _kPrimary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ctrl.couponSuccess ??
                          '${ctrl.appliedCouponCode} applied!',
                      style: const TextStyle(
                          fontSize: 12,
                          color: _kPrimaryDk,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: ctrl.removeCoupon,
                    child: const Text('Remove',
                        style: TextStyle(
                            fontSize: 11,
                            color: _kRed,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],

          // Available coupons list
          if (coupons.isNotEmpty && !ctrl.hasCouponApplied) ...[
            const SizedBox(height: 14),
            const Text('Available for you',
                style: TextStyle(fontSize: 11, color: _kMuted)),
            const SizedBox(height: 8),
            ...coupons.map((c) => _CouponListItem(
              coupon: c,
              isSelected: ctrl.appliedCouponId == c.id,
              onTap: () => ctrl.selectAvailableCoupon(c),
            )),
          ],
        ],
      ),
    );
  }
}

class _CouponListItem extends StatelessWidget {
  final AvailableCoupon coupon;
  final bool isSelected;
  final VoidCallback onTap;
  const _CouponListItem({
    required this.coupon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimaryLt : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _kPrimaryMd : _kBorder,
          ),
        ),
        child: Row(
          children: [
            // radio dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _kPrimary : Colors.transparent,
                border: Border.all(
                    color: isSelected ? _kPrimary : _kMuted, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            // code
            Text(
              coupon.code,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _kPrimaryDk,
                  letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                coupon.description ?? coupon.displayLabel,
                style: const TextStyle(fontSize: 11, color: _kMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kPrimaryLt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '₹${coupon.discountAmount.toStringAsFixed(0)} off',
                style: const TextStyle(
                    fontSize: 11,
                    color: _kPrimary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pricing Card
// ─────────────────────────────────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  final CoursePurchaseController ctrl;
  const _PricingCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = ctrl.discount > 0;
    final original = ctrl.originalTotal;
    final total = ctrl.totalAmount;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💰', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Price Breakdown',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kText)),
            ],
          ),
          const SizedBox(height: 14),

          _PriceRow(
            label: 'Course fee',
            value: '₹${ctrl.courseFee.toStringAsFixed(0)}',
          ),
          _PriceRow(
            label: 'GST (${ctrl.gstRate.toStringAsFixed(0)}%)',
            value: '₹${ctrl.gstAmount.toStringAsFixed(2)}',
          ),
          if (hasDiscount)
            _PriceRow(
              label: 'Coupon discount',
              value: '– ₹${ctrl.discount.toStringAsFixed(0)}',
              valueColor: _kPrimary,
            ),

          const Divider(height: 20, thickness: 0.5, color: _kBorder),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kText)),
              Row(
                children: [
                  if (hasDiscount) ...[
                    Text(
                      '₹${original.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: _kMuted,
                          decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kPrimary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // You Pay box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kPrimaryLt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kPrimaryMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YOU PAY',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kPrimaryDk,
                        letterSpacing: 0.6)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _kPrimaryDk),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 10),
                      Text(
                        '₹${original.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _kPrimaryMd,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: _kPrimaryMd,
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasDiscount)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'You save ₹${ctrl.discount.toStringAsFixed(0)}!',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _PriceRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: _kMuted)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? _kText)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Plan Card
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentPlanCard extends StatelessWidget {
  final CoursePurchaseController ctrl;
  const _PaymentPlanCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isFull = ctrl.paymentPlan == 'full';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Payment Plan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kText)),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: ['full', 'instalment'].map((plan) {
                final active = ctrl.paymentPlan == plan;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ctrl.setPaymentPlan(plan),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                        active ? Border.all(color: _kBorder) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        plan == 'full' ? 'Pay Full' : 'Instalments',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? _kPrimary : _kMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Full pay
          if (isFull)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                children: [
                  const Text('Single payment',
                      style: TextStyle(fontSize: 12, color: _kMuted)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${ctrl.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _kText),
                  ),
                  const SizedBox(height: 4),
                  const Text('Immediate access to all content',
                      style: TextStyle(fontSize: 11, color: _kMuted)),
                ],
              ),
            )
          else ...[
            // Instalment info banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _kAmberLt,
                borderRadius: BorderRadius.circular(10),
                // FIX: withOpacity deprecated → Color.fromRGBO
                border: Border.all(
                    color: Color.fromRGBO(184, 92, 0, 0.3)),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pay in 2 easy instalments — enroll now, pay second half later',
                      style: TextStyle(fontSize: 12, color: _kAmber),
                    ),
                  ),
                ],
              ),
            ),

            // Instalment 1
            _InstalmentCard(
              number: 1,
              total: 2,
              dateLabel: 'Today',
              amount: ctrl.instalment1Amount,
              percentage: 50,
              isPayNow: true,
            ),
            const SizedBox(height: 8),

            // Instalment 2
            _InstalmentCard(
              number: 2,
              total: 2,
              dateLabel: ctrl.instalment2DueDate,
              amount: ctrl.instalment2Amount,
              percentage: 50,
              isPayNow: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _InstalmentCard extends StatelessWidget {
  final int number;
  final int total;
  final String dateLabel;
  final double amount;
  final int percentage;
  final bool isPayNow;

  const _InstalmentCard({
    required this.number,
    required this.total,
    required this.dateLabel,
    required this.amount,
    required this.percentage,
    required this.isPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: _kSurface,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text(
                  'Instalment $number of $total',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kText),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPayNow ? _kPrimaryLt : _kAmberLt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPayNow ? 'Pay Now' : 'Pay Later',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isPayNow ? _kPrimary : _kAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: _kMuted),
                        const SizedBox(width: 4),
                        Text('Due: $dateLabel',
                            style: const TextStyle(
                                fontSize: 11, color: _kMuted)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('$percentage% of total',
                        style: const TextStyle(
                            fontSize: 10, color: _kMuted)),
                  ],
                ),
                const Spacer(),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Method Card
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
  final CoursePurchaseController ctrl;
  final List<PaymentMethod> methods;
  const _PaymentMethodCard(
      {required this.ctrl, required this.methods});

  // FIX: orElse previously constructed PaymentMethod with all required fields
  // but `icon` could be missed. Now uses a proper const fallback.
  static final _kPayLaterFallback = PaymentMethod(
    key: 'pay_later',
    label: 'Pay Later',
    description: 'Register now, pay when ready',
    icon: 'pay_later',
  );

  @override
  Widget build(BuildContext context) {
    final mainMethods = methods.where((m) => !m.isPayLater).toList();
    final payLater = methods.firstWhere(
          (m) => m.isPayLater,
      orElse: () => _kPayLaterFallback,
    );

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💳', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Payment Method',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kText)),
            ],
          ),
          const SizedBox(height: 14),

          ...mainMethods.map((m) => _PayMethodTile(
            method: m,
            isSelected: ctrl.paymentMethod == m.key,
            onTap: () => ctrl.setPaymentMethod(m.key),
          )),

          const Divider(height: 20, thickness: 0.5, color: _kBorder),

          // Pay Later
          GestureDetector(
            onTap: () => ctrl.setPaymentMethod(payLater.key),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ctrl.paymentMethod == payLater.key
                    ? _kAmberLt
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ctrl.paymentMethod == payLater.key
                      ? _kAmber
                      : _kBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _kAmberLt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: _kAmber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pay Later',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kText)),
                        Text(payLater.description,
                            style: const TextStyle(
                                fontSize: 11, color: _kMuted)),
                      ],
                    ),
                  ),
                  _RadioDot(
                    selected: ctrl.paymentMethod == payLater.key,
                    color: _kAmber,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  const _PayMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  (Color, Color, IconData) get _iconStyle {
    switch (method.key) {
      case 'upi':
        return (_kPrimaryLt, _kPrimary,
        Icons.account_balance_wallet_outlined);
      case 'phonepe':
        return (_kPurpleLt, _kPurple, Icons.smartphone_rounded);
      case 'razorpay':
        return (_kAmberLt, _kAmber, Icons.flash_on_rounded);
      default:
        return (_kSurface, _kMuted, Icons.payment_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _iconStyle;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimaryLt : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? _kPrimaryMd : _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kText)),
                  Text(method.description,
                      style: const TextStyle(
                          fontSize: 11, color: _kMuted)),
                ],
              ),
            ),
            _RadioDot(selected: isSelected, color: _kPrimary),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  final Color color;
  const _RadioDot({required this.selected, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: selected ? color : Colors.transparent,
      border:
      Border.all(color: selected ? color : _kMuted, width: 2),
    ),
    child: selected
        ? const Icon(Icons.check_rounded,
        size: 10, color: Colors.white)
        : null,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom CTA Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  final CoursePurchaseController ctrl;
  final VoidCallback onTap;
  const _BottomCta({required this.ctrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: ctrl.isOrderLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: ctrl.paymentMethod == 'pay_later'
                ? _kAmber
                : _kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: ctrl.isOrderLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ctrl.paymentMethod == 'pay_later'
                    ? Icons.schedule_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                ctrl.ctaLabel,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kBorder),
      boxShadow: [
        BoxShadow(
          // FIX: withOpacity deprecated → Color.fromRGBO
          color: Color.fromRGBO(0, 0, 0, 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class _MetaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  const _MetaChip(
      {required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color ?? _kMuted),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: color ?? _kMuted)),
      ],
    ),
  );
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _AlertBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isError ? _kRedLt : _kPrimaryLt,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        // FIX: withOpacity deprecated → Color.fromRGBO
        color: isError
            ? Color.fromRGBO(229, 57, 53, 0.4)
            : Color.fromRGBO(29, 158, 117, 0.4),
      ),
    ),
    child: Row(
      children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          size: 14,
          color: isError ? _kRed : _kPrimary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(message,
              style: TextStyle(
                  fontSize: 12,
                  color: isError ? _kRed : _kPrimary)),
        ),
      ],
    ),
  );
}