import 'dart:convert';
import 'package:BookMyTeacher/core/constants/image_paths.dart';
import 'package:BookMyTeacher/presentation/widgets/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/app_config.dart';
import '../../providers/user_provider.dart';
import '../widgets/account_manage_page.dart';
import '../widgets/invite_bottom_sheet.dart';
import 'account/join_community_sheet.dart';
import 'account/profile_option_tile.dart';
import 'account/app_details_sheet.dart';
import 'account/connect_with_us_sheet.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    if (userAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = userAsync.value;

    // Default values
    String name = "";
    String email = "";
    String avatar = "";
    String accountStatus = "";

    if (user != null) {
      name = user.name ?? "";
      email = user.email ?? "";
      avatar = user.avatarUrl ?? "";
      accountStatus = user.accountStatus ?? "";
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(ImagePaths.appBg, fit: BoxFit.cover),
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
                padding: const EdgeInsets.only(top: 150, left: 25, right: 25),
                children: [
                  ProfileOptionTile(
                    icon: Icons.person_outline,
                    title: 'Account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountManagePage(),
                        ),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    icon: Icons.group_add_outlined,
                    title: 'Invite Friends',
                    onTap: () async => _openInviteSheet(context),
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
                CircleAvatar(
                  radius: 60,
                  backgroundImage: avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : const AssetImage('assets/images/avatar.png')
                  as ImageProvider,
                ),
                const SizedBox(height: 25),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email.isNotEmpty ? email : "Unknown email",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
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

  void _openInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InviteBottomSheet(),
    );
  }
}