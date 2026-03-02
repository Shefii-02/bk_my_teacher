import 'dart:convert' show base64Encode, jsonEncode, utf8;
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import '../widgets/merchant_app_phonepe.dart';

class PhonepePg {
  int amount;
  BuildContext context;

  PhonepePg({required this.context, required this.amount});
  String marchentId = "PGTESTPAYUAT";
  String salt = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  int saltIndex = 1;
  String callbackURL = "https://www.webhook.site/callback-url";
  String apiEndPoint = "/pg/v1/pay";

  init() {
    PhonePePaymentSdk.init(
      "SANDBOX",
      marchentId,
      '1',
      true,
    );
  }

  startTransaction() async {
    final String transactionId =
        "TXN${DateTime.now().millisecondsSinceEpoch}";

    Map<String, dynamic> body = {
      "merchantId": marchentId,
      "merchantTransactionId": transactionId,
      "merchantUserId": "USER123",
      "amount": amount * 100, // paisa
      "callbackUrl": callbackURL,
      "mobileNumber": "9876543210",
      "paymentInstrument": {
        "type": "PAY_PAGE"
      }
    };

    // ✅ Convert Map → JSON STRING
    String request = jsonEncode(body);

    try {
      final result = await PhonePePaymentSdk.startTransaction(
        request,
        "coin.bookmyteacher.app", // MUST MATCH applicationId
      );

      log("Payment Result => $result");

      if (result != null && result['status'] == 'SUCCESS') {
        log("✅ Payment Successful");
      } else if (result != null && result['status'] == 'FAILURE') {
        log("❌ Payment Failed");
      } else {
        log("⚠️ Payment Cancelled");
      }
    } catch (e) {
      log("Payment Exception => $e");
    }
  }



}