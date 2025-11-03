import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectWithTeam extends StatefulWidget {
  const ConnectWithTeam({super.key});

  @override
  State<ConnectWithTeam> createState() => _ConnectWithTeamState();
}

class _ConnectWithTeamState extends State<ConnectWithTeam> {
  @override
  Widget build(BuildContext context) {
    return         ElevatedButton.icon(
      onPressed: () {
        openWhatsApp(
          context,
          phone: "917510115544",
          message:
          "Hello, I want to connect with your team.",
        );
      },
      icon: const Icon(
        Icons.chat_bubble,
        color: Colors.white,
        size: 20,
      ),
      label: const Text(
        "Connect With Our Team",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
      ),
    );
  }

}

void openWhatsApp(
    BuildContext context, {
      required String phone,
      required String message,
    }) async {
  final url = Uri.parse(
    "https://wa.me/$phone?text=${Uri.encodeFull(message)}",
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cannot open WhatsApp")));
  }
}
