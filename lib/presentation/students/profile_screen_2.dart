import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/presentation/widgets/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/account_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentProfileAsync = ref.watch(studentProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: studentProfileAsync.when(
        data: (student) => Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(AppConfig.bodyBg, fit: BoxFit.cover),
            ),

            // Foreground white container
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.73,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 180, 180, 180),
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: 100, left: 25, right: 25),
                  children: [
                    ProfileOptionTile(
                      icon: Icons.person_outline,
                      title: 'Account',
                      onTap: () {
                        // navigate to account manage
                      },
                    ),
                    ProfileOptionTile(
                      icon: Icons.group_add_outlined,
                      title: 'Invite Friends',
                      onTap: () =>
                          _showSheet(context, const InviteFriendsSheet()),
                    ),
                    ProfileOptionTile(
                      icon: Icons.people_alt_outlined,
                      title: 'Join our Community',
                      onTap: () =>
                          _showSheet(context, const JoinCommunitySheet()),
                    ),
                    ProfileOptionTile(
                      icon: Icons.headphones_outlined,
                      title: 'Connect with Us',
                      onTap: () =>
                          _showSheet(context, const ConnectWithUsSheet()),
                    ),
                    ProfileOptionTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      ),
                    ),
                    ProfileOptionTile(
                      icon: Icons.info_outline,
                      title: 'App Details',
                      onTap: () => _showSheet(context, const AppDetailsSheet()),
                    ),
                  ],
                ),
              ),
            ),

            // Profile image and name
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // CircleAvatar(
                  //   radius: 60,
                  //   backgroundImage: student.avatarUrl.isNotEmpty
                  //       ? NetworkImage(student.avatarUrl)
                  //       : const AssetImage('assets/images/avatar.png')
                  //             as ImageProvider,
                  // ),
                  const SizedBox(height: 12),
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Text(
                  //   student.email,
                  //   style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  // ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Failed to load profile: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => sheet,
    );
  }
}

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class InviteFriendsSheet extends StatelessWidget {
  const InviteFriendsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Invite Friends",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text("Share Invite Link"),
          ),
        ],
      ),
    );
  }
}

class JoinCommunitySheet extends StatelessWidget {
  const JoinCommunitySheet({super.key});
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
            "Join Our Community",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Stay connected and grow with others! Join our online communities below.",
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.telegram, color: Colors.blue),
            title: const Text("Telegram Group"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.discord, color: Colors.indigo),
            title: const Text("Discord Server"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.reddit, color: Colors.orange),
            title: const Text("Reddit Community"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.facebook, color: Colors.blueAccent),
            title: const Text("Facebook Group"),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ConnectWithUsSheet extends StatelessWidget {
  const ConnectWithUsSheet({super.key});
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
          const Text("We’d love to hear from you! Reach out via:"),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.redAccent),
            title: const Text("support@bookmyteacher.com"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text("+91 98765 43210"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.public, color: Colors.blueAccent),
            title: const Text("www.bookmyteacher.com"),
            onTap: () {},
          ),
          const Divider(),
          const Text(
            "Follow us on",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.facebook, color: Colors.blueAccent, size: 30),
              Icon(Icons.camera_alt, color: Colors.purple, size: 30),
              Icon(Icons.play_circle_fill, color: Colors.red, size: 30),
              Icon(Icons.alternate_email, color: Colors.lightBlue, size: 30),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class AppDetailsSheet extends StatelessWidget {
  const AppDetailsSheet({super.key});
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
            "App Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Version"),
            trailing: Text("1.0.0"),
          ),
          const ListTile(
            leading: Icon(Icons.date_range),
            title: Text("Release Date"),
            trailing: Text("Nov 2025"),
          ),
          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text("Developed By"),
            trailing: Text("BookMyTeacher Team"),
          ),
          const ListTile(
            leading: Icon(Icons.verified_user),
            title: Text("License"),
            trailing: Text("Open Source"),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
            onTap: null,
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text("Terms & Conditions"),
            onTap: null,
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
