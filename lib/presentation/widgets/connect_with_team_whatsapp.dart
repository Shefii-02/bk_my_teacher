import 'package:flutter/material.dart';

import '../../services/browser_service.dart';

class ConnectWithTeamWhatsapp extends StatefulWidget {
  const ConnectWithTeamWhatsapp({super.key});

  @override
  State<ConnectWithTeamWhatsapp> createState() =>
      _ConnectWithTeamWhatsappState();
}

class _ConnectWithTeamWhatsappState extends State<ConnectWithTeamWhatsapp> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        openWhatsApp(
          context,
          phone: "917510115544",
          message: "Hello, I want to connect with your team.",
        );
      },
      icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
      ),
    );
  }
}
