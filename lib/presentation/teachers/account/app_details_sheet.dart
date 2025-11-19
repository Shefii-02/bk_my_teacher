import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDetailsSheet extends StatefulWidget {
  const AppDetailsSheet({super.key});

  @override
  State<AppDetailsSheet> createState() => _AppDetailsSheetState();
}

class _AppDetailsSheetState extends State<AppDetailsSheet> {
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    loadAppInfo();
  }

  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  // Open a URL in browser
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // Open Play Store
  Future<void> openPlayStore() async {
    const playStoreUrl =
        "https://play.google.com/store/apps/details?id=coin.bookmyteacher.app";
    await openUrl(playStoreUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Wrap(
        runSpacing: 15,
        children: [
          // Top handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "App Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // Version number
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Version"),
            trailing: Text(version.isNotEmpty ? version : "Loading..."),
          ),

          // Build number
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text("Build Number"),
            trailing: Text(buildNumber),
          ),

          const ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text("Initial Release"),
            trailing: Text("November 2025"),
          ),

          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text("Developed By"),
            trailing: Text("BookMyTeacher Team"),
          ),

          // Privacy Policy link
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openUrl(
                "https://bookmyteacher.co.in/privacy-policy"), // CHANGE URL
          ),

          // Terms and Conditions link
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Terms & Conditions"),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openUrl(
                "https://bookmyteacher.co.in/terms-and-conditions"), // CHANGE URL
          ),


          // Check for updates
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text("Check for Updates"),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: openPlayStore,
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              "© 2025 BookMyTeacher. All rights reserved.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
