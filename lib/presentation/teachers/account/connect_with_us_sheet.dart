import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/api_service.dart';

class ConnectWithUsSheet extends StatefulWidget {
  const ConnectWithUsSheet({super.key});

  @override
  State<ConnectWithUsSheet> createState() => _ConnectWithUsSheetState();
}

class _ConnectWithUsSheetState extends State<ConnectWithUsSheet> {
  Map<String, dynamic> connectData = {
    "contact": {},
    "socials": [],
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ApiService().fetchConnectData();
    setState(() => connectData = data);
  }

  @override
  Widget build(BuildContext context) {
    final contact = connectData['contact'];
    final socials = connectData['socials'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Wrap(
        runSpacing: 15,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Connect With Us",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // Contact Details
          if (contact['email'] != null)
            ListTile(
              leading: const Icon(Icons.email, color: Colors.redAccent),
              title: Text(contact['email']),
              onTap: () => _launch(contact['email'], type: "email"),
            ),
          //
          if (contact['phone'] != null)
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(contact['phone']),
              onTap: () => _launch(contact['phone'], type: "phone"),
            ),
          //
          if (contact['website'] != null)
            ListTile(
              leading: const Icon(Icons.public, color: Colors.blueAccent),
              title: Text(contact['website']),
              onTap: () => _launch(contact['website']),
            ),

          const Divider(),

          // Social Icons
          const Text(
            "Follow us on",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (socials.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: socials.map<Widget>((item) {
                return GestureDetector(
                  onTap: () => _launch(item['link']),
                  child: Image.network(
                    item['icon'],
                    width: 35,
                    height: 35,
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _launch(String value, {String type = "url"}) async {
    Uri uri;

    switch (type) {
      case "email":
        uri = Uri(
          scheme: 'mailto',
          path: value,
        );
        break;

      case "phone":
        uri = Uri(
          scheme: 'tel',
          path: value,
        );
        break;

      case "sms":
        uri = Uri(
          scheme: 'sms',
          path: value,
        );
        break;

      default:
      // Normal website URL
        uri = Uri.parse(value);
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      print("❌ Could not launch: $value");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to open link")),
      );
    }
  }

}
