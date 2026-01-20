import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class UnifiedPaymentPage extends StatefulWidget {
  const UnifiedPaymentPage({super.key});

  @override
  State<UnifiedPaymentPage> createState() => _UnifiedPaymentPageState();
}

class _UnifiedPaymentPageState extends State<UnifiedPaymentPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _iosProduct;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _initIOS();
    } else {
      _loading = false;
    }
  }

  /// ---------- iOS IAP ----------
  Future<void> _initIOS() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    const ids = {'course_20'};
    final response = await _iap.queryProductDetails(ids);

    if (response.productDetails.isNotEmpty) {
      _iosProduct = response.productDetails.first;
    }

    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
    setState(() => _loading = false);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // TODO: send receipt to Laravel
        await _iap.completePurchase(purchase);

        if (mounted) {
          _showSuccess();
        }
      } else if (purchase.status == PurchaseStatus.error) {
        _showError("Payment failed");
      }
    }
  }

  void _buyIOS() {
    if (_iosProduct == null) return;
    final param = PurchaseParam(productDetails: _iosProduct!);
    _iap.buyNonConsumable(purchaseParam: param);
  }

  /// ---------- ANDROID PhonePe ----------
  Future<void> _buyAndroid() async {
    // Call your Laravel API to get PhonePe payment URL
    final phonePeUrl = "https://phonepe-payment-url-from-backend";

    await launchUrl(
      Uri.parse(phonePeUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  /// ---------- COMMON ----------
  void _payNow() {
    if (Platform.isIOS) {
      _buyIOS();
    } else {
      _buyAndroid();
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful ✅")),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unlock Course")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_open, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Premium Course Access",
                style:
                TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "One-time payment",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Text(
                "₹20",
                style:
                TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _payNow,
                  child: Text(
                    Platform.isIOS ? "Pay with Apple" : "Pay ₹20",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (Platform.isIOS)
                TextButton(
                  onPressed: () => _iap.restorePurchases(),
                  child: const Text("Restore Purchase"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
