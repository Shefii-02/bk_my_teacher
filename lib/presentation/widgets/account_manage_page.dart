import 'package:BookMyTeacher/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../services/launch_status_service.dart';
import '../../services/settings_service.dart';
import '../auth/controller/auth_controller.dart';
import 'my_performance_page.dart';

class AccountManagePage extends ConsumerStatefulWidget {
  const AccountManagePage({super.key});

  @override
  ConsumerState<AccountManagePage> createState() => _AccountManagePageState();
}

class _AccountManagePageState extends ConsumerState<AccountManagePage> {
  bool chatEnabled = false;
  bool commentEnabled = false;
  bool groupStudyEnabled = false;

  @override
  void initState() {
    super.initState();

    // Load values from Hive
    commentEnabled = SettingsService.getBool("comment_option", defaultValue: true);
    chatEnabled = SettingsService.getBool("chat_option", defaultValue: true);
    groupStudyEnabled = SettingsService.getBool("group_study_option", defaultValue: true);
  }

  void _updateToggle(bool v, String name) {
    setState(() {
      if (name == 'chat_option') chatEnabled = v;
      if (name == 'comment_option') commentEnabled = v;
      if (name == 'group_study_option') groupStudyEnabled = v;
    });

    SettingsService.setBool(name, v);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Management"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: "Profile"),
          _AccountOptionTile(
            icon: Icons.person_outline,
            title: "Profile Manage",
            subtitle: "Edit your personal details",
            onTap: () => _openBottomSheet(context, "Profile Manage"),
          ),
          _AccountOptionTile(
            icon: Icons.school_outlined,
            title: "Teaching Manage",
            subtitle: "Manage your subjects, grades, and syllabus",
            onTap: () => _openBottomSheet(context, "Teaching Manage"),
          ),
          const Divider(),

          const _SectionHeader(title: "Social & Communication"),
          _SwitchOptionTile(
            icon: Icons.chat_outlined,
            title: "Chat Option",
            value: chatEnabled,
            subtitle: "Enable or disable chat access",
            // onChanged: (v) => setState(() => chatEnabled = v),
            onChanged: (v) => _updateToggle(v, "chat_option"),
          ),

          _SwitchOptionTile(
            icon: Icons.comment_outlined,
            title: "Comment Option",
            value: commentEnabled,
            subtitle: "Allow others to comment on your posts",
            onChanged: (v) => _updateToggle(v, "comment_option"),
          ),

          _SwitchOptionTile(
            icon: Icons.groups_outlined,
            title: "Group Study Features",
            value: groupStudyEnabled,
            subtitle: "Enable group study participation",
            onChanged: (v) => _updateToggle(v, "group_study_option"),
          ),
          const Divider(),

          const _SectionHeader(title: "Performance"),
          _AccountOptionTile(
            icon: Icons.bar_chart_outlined,
            title: "My Performance",
            subtitle: "Track your academic performance",
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const MyPerformancePage(),
            ),
          ),

          const Divider(),

          const _SectionHeader(title: "Account Controls"),
          _AccountOptionTile(
            icon: Icons.logout_outlined,
            title: "Logout",
            subtitle: "Sign out from your account",
            onTap: () async {
              final confirmed = await _confirmAction(
                context,
                "Logout",
                "Are you sure you want to logout?",
              );
              if (confirmed) {
                ref.invalidate(userProvider);
                ref.invalidate(authControllerProvider);
                await ApiService().logout();
                await LaunchStatusService.resetApp();
                context.go('/auth');
              }
            },
          ),
          _AccountOptionTile(
            icon: Icons.delete_outline,
            title: "Request Delete Account",
            subtitle: "Permanently remove your account",
            onTap: () async {
              final confirmed = await _confirmAction(
                context,
                "Are you sure delete account",
                "This action cannot be undone. Do you really want to delete your account?",
              );
              if (confirmed) {
                ref.invalidate(userProvider);
                ref.invalidate(authControllerProvider);
                await ApiService().requestDeleteAccount();
                await LaunchStatusService.resetApp();
                if (context.mounted) context.go('/auth');
                // Delete account API call
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// BottomSheet for managing selected section
  void _openBottomSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Center(
                child: Text(
                  type == "profile" ? "Profile Manage" : "Teaching Manage",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// VIEW
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("View details"),
                onTap: () {
                  Navigator.pop(context);
                  if (type == "Profile Manage") context.push("/personal/view");
                  if (type == "Teaching Manage") context.push("/teaching/view");
                },
              ),

              /// EDIT
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text("Edit settings"),
                onTap: () {
                  Navigator.pop(context);
                  if (type == "Profile Manage") context.push("/personal-info");
                  if (type == "Teaching Manage") context.push("/teaching-details");
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  /// Common confirmation dialog
  static Future<bool> _confirmAction(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }

}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

/// Tile for bottomsheet-based options
class _AccountOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _AccountOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue.shade700),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

/// Tile for switch-based options
class _SwitchOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green.shade50,
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
