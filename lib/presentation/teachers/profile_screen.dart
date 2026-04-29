// import 'dart:convert';
// import 'package:BookMyTeacher/presentation/students/student_account_manage_page.dart';
// import 'package:BookMyTeacher/presentation/widgets/settings_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/constants/image_paths.dart';
// import '../../core/enums/app_config.dart';
// import '../../providers/user_provider.dart';
// import '../teachers/account/app_details_sheet.dart';
// import '../teachers/account/connect_with_us_sheet.dart';
// import '../teachers/account/join_community_sheet.dart';
// import '../teachers/account/profile_option_tile.dart';
// import '../widgets/account_manage_page.dart';
// import '../widgets/invite_bottom_sheet.dart';
//
//
// class ProfileScreen extends ConsumerStatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userAsync = ref.watch(userProvider);
//
//     if (userAsync.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     final user = userAsync.value;
//
//     // Default values
//     String name = "";
//     String email = "";
//     String avatar = "";
//     String accountStatus = "";
//
//     if (user != null) {
//       name = user.name ?? "";
//       email = user.email ?? "";
//       avatar = user.avatarUrl ?? "";
//       accountStatus = user.accountStatus ?? "";
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Image.asset(ImagePaths.appBg, fit: BoxFit.cover),
//           ),
//
//           // Foreground white container
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.73,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color.fromARGB(255, 180, 180, 180),
//                     blurRadius: 12,
//                     offset: Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: ListView(
//                 padding: const EdgeInsets.only(top: 100, left: 25, right: 25),
//                 children: [
//                   ProfileOptionTile(
//                     icon: Icons.person_outline,
//                     title: 'Account',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const StudentAccountManagePage(),
//                         ),
//                       );
//                     },
//                   ),
//                   ProfileOptionTile(
//                     icon: Icons.group_add_outlined,
//                     title: 'Invite Friends',
//                     onTap: () async => _openInviteSheet(context),
//                   ),
//                   ProfileOptionTile(
//                     icon: Icons.people_alt_outlined,
//                     title: 'Join our Community',
//                     onTap: () =>
//                         _showSheet(context, const JoinCommunitySheet()),
//                   ),
//                   ProfileOptionTile(
//                     icon: Icons.headphones_outlined,
//                     title: 'Connect with Us',
//                     onTap: () =>
//                         _showSheet(context, const ConnectWithUsSheet()),
//                   ),
//                   ProfileOptionTile(
//                     icon: Icons.settings_outlined,
//                     title: 'Settings',
//                     onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SettingsPage()),
//                     ),
//                   ),
//                   ProfileOptionTile(
//                     icon: Icons.info_outline,
//                     title: 'App Details',
//                     onTap: () => _showSheet(context, const AppDetailsSheet()),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Profile image and name
//           Positioned(
//             top: 80,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundImage: avatar.isNotEmpty
//                       ? NetworkImage(avatar)
//                       : const AssetImage('assets/images/avatar.png')
//                   as ImageProvider,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   name,
//                   style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   email.isNotEmpty ? email : "Unknown email",
//                   style: TextStyle(color: Colors.grey[700], fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSheet(BuildContext context, Widget sheet) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => sheet,
//     );
//   }
//
//   void _openInviteSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => InviteBottomSheet(),
//     );
//   }
// }

import 'package:BookMyTeacher/core/constants/extensions.dart';
import 'package:BookMyTeacher/presentation/students/accounts/profile_option_tile.dart';
import 'package:BookMyTeacher/presentation/widgets/account_manage_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/image_paths.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_router.dart';
import '../teachers/account/app_details_sheet.dart';
import '../teachers/account/connect_with_us_sheet.dart';
import '../teachers/account/join_community_sheet.dart';
import '../widgets/invite_bottom_sheet.dart';
import '../widgets/settings_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    if (userAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userAsync.value;
    final String name = user?.name ?? '';
    final String email = user?.email ?? '';
    final String mobile = user?.mobile ?? '';
    final String avatar = user?.avatarUrl ?? '';
    final String accountStatus = user?.accountStatus ?? 'Active';
    final String accType = user?.accType ?? 'Student';

    return Scaffold(
      backgroundColor: const Color(0xFF0E0C14),
      body: Stack(
        children: [
          // ── Dark gradient header ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child:
            // Image.asset(ImagePaths.appBg, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF50CC8A),
                    Color(0xFFC0F3D6),
                    Color(0xFF50CC8A),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Soft glow at the bottom of the header
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.bottomCenter,
                          radius: 1.0,
                          colors: [
                            Color(0x227C5CFC),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Back / more buttons
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // _HeaderIconButton(
                          //   icon: Icons.arrow_back_ios_new_rounded,
                          //   onTap: () => context.pushReplacement('/student-dashboard'),
                          // ),
                          // _HeaderIconButton(
                          //   icon: Icons.more_vert_rounded,
                          //   onTap: () {},
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── White bottom sheet ────────────────────────────────────────
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      name.isNotEmpty ? name : 'Student',
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      email.isNotEmpty ? email : 'No email',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      mobile.isNotEmpty ? mobile : 'No email',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Status badge
                    _StatusBadge(status: accType.capitalize()),
                    const SizedBox(height: 28),

                    // ── Section: My Account ──────────────────────────
                    _SectionLabel(label: 'My Account'),
                    const SizedBox(height: 10),
                    _TileGroup(
                      tiles: [
                        ProfileOptionTile(
                          icon: Icons.person_outline_rounded,
                          iconBgColor: const Color(0xFFF0EBFF),
                          iconColor: const Color(0xFF7C5CFC),
                          title: 'Account',
                          subtitle: 'Manage profile & details',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountManagePage(),
                            ),
                          ),
                        ),
                        ProfileOptionTile(
                          icon: Icons.settings_outlined,
                          iconBgColor: const Color(0xFFF1F5F9),
                          iconColor: const Color(0xFF64748B),
                          title: 'Settings',
                          subtitle: 'Notifications, privacy',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Section: Community ───────────────────────────
                    _SectionLabel(label: 'Community'),
                    const SizedBox(height: 10),
                    _TileGroup(
                      tiles: [
                        ProfileOptionTile(
                          icon: Icons.group_add_outlined,
                          iconBgColor: const Color(0xFFFFF1F2),
                          iconColor: const Color(0xFFF43F5E),
                          title: 'Invite Friends',
                          subtitle: 'Share & earn rewards',
                          badge: 'New',
                          onTap: () => _openInviteSheet(context),
                        ),
                        ProfileOptionTile(
                          icon: Icons.people_alt_outlined,
                          iconBgColor: const Color(0xFFF0FDF9),
                          iconColor: const Color(0xFF0D9488),
                          title: 'Join our Community',
                          subtitle: 'Connect with learners',
                          onTap: () => _showSheet(context, const JoinCommunitySheet()),
                        ),
                        ProfileOptionTile(
                          icon: Icons.headphones_outlined,
                          iconBgColor: const Color(0xFFEFF6FF),
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Connect with Us',
                          subtitle: 'Support & feedback',
                          onTap: () => _showSheet(context, const ConnectWithUsSheet()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Section: More ────────────────────────────────
                    _SectionLabel(label: 'More'),
                    const SizedBox(height: 10),
                    _TileGroup(
                      tiles: [
                        ProfileOptionTile(
                          icon: Icons.info_outline_rounded,
                          iconBgColor: const Color(0xFFFFFBEB),
                          iconColor: const Color(0xFFD97706),
                          title: 'App Details',
                          subtitle: 'Version & licenses',
                          onTap: () => _showSheet(context, const AppDetailsSheet()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Sign Out ─────────────────────────────────────
                    // _SignOutButton(onTap: () {}),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating avatar ───────────────────────────────────────────
          Positioned(
            top: 75,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFF50CC8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C5CFC).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFF2D2245),
                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty
                      ? Text(
                    _initials(name),
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD4BBFF),
                    ),
                  )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
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
      builder: (_) => InviteBottomSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF7C5CFC),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Acc Type · $status',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6D28D9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFB8B0CC),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TileGroup extends StatelessWidget {
  final List<ProfileOptionTile> tiles;
  const _TileGroup({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: tiles
            .asMap()
            .entries
            .map(
              (e) => Column(
            children: [
              e.value,
              if (e.key < tiles.length - 1)
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEDE9F8),
                  indent: 18,
                  endIndent: 18,
                ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFF43F5E), size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF43F5E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}