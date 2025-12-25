import 'package:BookMyTeacher/presentation/widgets/show_failed_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/api_service.dart';
import '../../widgets/show_success_alert.dart';

class ReferralPopup extends StatefulWidget {
  final BuildContext parentContext;
  final String? redirectionUrl;
  const ReferralPopup({
    super.key,
    required this.parentContext,
    this.redirectionUrl,
  });

  @override
  State<ReferralPopup> createState() => _ReferralPopupState();
}

class _ReferralPopupState extends State<ReferralPopup> {
  final TextEditingController _refCtrl = TextEditingController();
  bool _isLoading = false;


  String? _alertMessage;
  Color? _alertColor;

  @override
  void initState() {
    super.initState();
    _loadReferralCode(); // Load ONCE
  }

  void _loadReferralCode() async {
    final response = await ApiService().takeReferral();

    if (response['success'] == true && response['code'] != "") {
      setState(() {
        _refCtrl.text = response['code'];
      });
    }
  }

  Future<void> _submitReferral() async {
    if (_refCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a referral code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().applyReferralProvider(
        _refCtrl.text.trim(),
      );

      if (!mounted) return;

      if (response["status"] == true) {
        setState(() {
          _alertMessage = response["message"] ?? "Referral applied";
          _alertColor = Colors.green;
        });

        // Optional redirect after 1 sec
        Future.delayed(const Duration(seconds: 1), () {
          if (widget.redirectionUrl != null) {
            // final redirectTo = widget.redirectionUrl ?? '/';
            // context.go(redirectTo);
            context.go('/');
          }
        });
      } else {
        setState(() {
          _alertMessage = response["message"] ?? "Error applying referral";
          _alertColor = Colors.red;
        });
      }

      // if (response["status"] == true) {
      //   ShowSuccessAlert(
      //     title: "Success",
      //     subtitle: response["message"] ?? "Referral applied",
      //     timer: 3,
      //     color: Colors.green,
      //   );
      //
      //   // ScaffoldMessenger.of(context).showSnackBar(
      //   //   SnackBar(content: Text()),
      //   // );
      //
      //   Navigator.pop(context);
      //   context.go('/');
      // } else {
      //   print('object');
      //
      //   ShowSuccessAlert(
      //     title: "Error",
      //     subtitle: response["message"] ?? "Error applying referral",
      //     timer: 3,
      //     color: Colors.red,
      //   );
      // }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _alertMessage = "Error: $e";
        _alertColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Have a Referral Code?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Enter the referral code shared with you to earn rewards.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _refCtrl,
              decoration: InputDecoration(
                hintText: "Enter referral code",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (_alertMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _alertColor ?? Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _alertMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Skip"),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReferral,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }
}
