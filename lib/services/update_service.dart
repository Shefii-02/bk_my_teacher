import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    final newVersion = NewVersionPlus(
      androidId: "coin.bookmyteacher.app",
    );

    final status = await newVersion.getVersionStatus();

    if (status != null && status.canUpdate) {
      // Mandatory update alert
      showDialog(
        context: context,
        barrierDismissible: false, // cannot dismiss
        builder: (context) => WillPopScope(
          onWillPop: () async => false, // disable back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Update Required 🚨",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "A new version (${status.storeVersion}) of the app is available.\n\n"
                  "You must update to continue using the app.",
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // ✅ pass the store URL now
                  newVersion.launchAppStore(status.appStoreLink);
                },
                child: const Text("Update Now"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
