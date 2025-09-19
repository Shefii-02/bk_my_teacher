import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(
    BuildContext context, {
      required String phone,
      required String message,
    }) async {
  final encodedMessage = Uri.encodeComponent(message);

  // WhatsApp deep link (works only if app installed)
  final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$phone&text=$encodedMessage");

  // Web fallbacks (browser)
  final Uri webUrl = Uri.parse("https://wa.me/$phone?text=$encodedMessage");
  final Uri webUrl2 = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");

  try {
    if (await canLaunchUrl(whatsappUrl)) {
      // ✅ Open WhatsApp app directly
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
      // ✅ Open wa.me in browser
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl2)) {
      // ✅ Open api.whatsapp.com in browser
      await launchUrl(webUrl2, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp not available on this device.")),
      );
    }
  } catch (e) {
    debugPrint("❌ Error launching WhatsApp: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unable to open WhatsApp: $e")),
    );
  }
}
