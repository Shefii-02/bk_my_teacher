import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme_provider.dart';


class SettingsPage
    extends ConsumerStatefulWidget {

  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends ConsumerState<SettingsPage> {

  bool darkMode = false;

  final Map<String, Permission> permissions = {

    "Camera": Permission.camera,

    "Microphone": Permission.microphone,

    "Photos": Permission.photos,

    "Videos": Permission.videos,

    "Audio": Permission.audio,

    "Location": Permission.location,

    "Contacts": Permission.contacts,

    "Notification": Permission.notification,

    "Manage Storage":
    Permission.manageExternalStorage,
  };

  Map<String,bool> permissionStatus = {};

  @override
  void initState() {
    super.initState();

    darkMode =
        ref.read(themeProvider) ==
            ThemeMode.dark;

    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {

    final statuses =
    <String,bool>{};

    for (var entry in permissions.entries) {

      final status =
      await entry.value.status;

      statuses[entry.key] =
          status.isGranted;
    }

    if(mounted){
      setState(() {
        permissionStatus = statuses;
      });
    }
  }

  Future<void> _requestPermission(
      String key
      ) async {

    final permission =
    permissions[key]!;

    final status =
    await permission.status;

    if(status.isGranted){

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '$key already granted',
          ),
        ),
      );

      return;
    }

    if(status.isPermanentlyDenied){

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '$key denied permanently. Opening settings...',
          ),
        ),
      );

      await openAppSettings();

      return;
    }

    final result =
    await permission.request();

    if(mounted){
      setState(() {
        permissionStatus[key] =
            result.isGranted;
      });
    }
  }

  void _updateTheme(bool v){

    setState(() {
      darkMode = v;
    });

    ref
        .read(themeProvider.notifier)
        .toggle(v);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "App Settings",
        ),
      ),

      body: ListView(
        children: [

          SwitchListTile(
            title: const Text(
              "Enable Dark Mode",
            ),

            value: darkMode,

            onChanged: (v) =>
                _updateTheme(v),

            secondary:
            const Icon(
              Icons.dark_mode,
            ),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "App Permissions",
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          ...permissions.keys.map(
                (key){

              final granted =
                  permissionStatus[key]
                      ?? false;

              return SwitchListTile(

                title: Text(key),

                secondary: Icon(
                  _getPermissionIcon(key),

                  color: granted
                      ? Colors.green
                      : Colors.grey,
                ),

                value: granted,

                onChanged: (_){
                  _requestPermission(
                    key,
                  );
                },
              );

            },
          ),

        ],
      ),
    );
  }

  IconData _getPermissionIcon(
      String key
      ) {

    switch(key){

      case "Camera":
        return Icons.camera_alt;

      case "Microphone":
        return Icons.mic;

      case "Photos":
        return Icons.photo;

      case "Videos":
        return Icons.video_library;

      case "Audio":
        return Icons.audiotrack;

      case "Location":
        return Icons.location_on;

      case "Contacts":
        return Icons.contacts;

      case "Notification":
        return Icons.notifications;

      case "Manage Storage":
        return Icons.folder_copy;

      default:
        return Icons.settings;
    }

  }

}