import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notification = false;
  bool darkMode = false;

  final Map<String, Permission> permissions = {
    "Camera": Permission.camera,
    "Microphone": Permission.microphone,
    "Storage / Files": Permission.storage,
    "Photos": Permission.photos,
    "Location": Permission.location,
    "Contacts": Permission.contacts,
    "Notification": Permission.notification,
  };

  Map<String, bool> permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    final Map<String, bool> statuses = {};
    for (var entry in permissions.entries) {
      final status = await entry.value.status;
      statuses[entry.key] = status.isGranted;
    }
    setState(() => permissionStatus = statuses);
  }

  Future<void> _requestPermission(String key) async {
    final permission = permissions[key]!;
    final status = await permission.status;

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$key permission already granted.')),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$key permission permanently denied. Opening app settings...')),
      );
      await openAppSettings();
      return;
    }

    final result = await permission.request();
    setState(() {
      permissionStatus[key] = result.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Settings")),
      body: ListView(
        children: [
          // 🌙 Dark Mode
          SwitchListTile(
            title: const Text("Enable Dark Mode"),
            value: darkMode,
            onChanged: (v) => setState(() => darkMode = v),
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),

          // 🔒 Permissions
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "App Permissions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...permissions.keys.map((key) {
            final granted = permissionStatus[key] ?? false;
            return SwitchListTile(
              title: Text(key),
              secondary: Icon(
                _getPermissionIcon(key),
                color: granted ? Colors.green : Colors.grey,
              ),
              value: granted,
              onChanged: (_) => _requestPermission(key),
            );
          }),
        ],
      ),
    );
  }

  IconData _getPermissionIcon(String key) {
    switch (key) {
      case "Camera":
        return Icons.camera_alt;
      case "Microphone":
        return Icons.mic;
      case "Storage / Files":
        return Icons.folder;
      case "Photos":
        return Icons.photo;
      case "Location":
        return Icons.location_on;
      case "Contacts":
        return Icons.contacts;
      case "Notification":
        return Icons.notifications;
      default:
        return Icons.settings;
    }
  }
}
