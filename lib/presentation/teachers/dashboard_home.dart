import 'dart:ui';
import 'package:BookMyTeacher/presentation/teachers/account_message_card.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/achievements_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/rating_reviews.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/watch_time_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/spend_time_card.dart';
import 'package:BookMyTeacher/presentation/teachers/student_achievement_card_section.dart';
import 'package:BookMyTeacher/presentation/teachers/student_reviews_scroll_section.dart';
import 'package:BookMyTeacher/presentation/teachers/teacher_quick_actions.dart';
import 'package:BookMyTeacher/presentation/teachers/watch_time_card.dart';
import 'package:BookMyTeacher/presentation/widgets/social_media_icons.dart';
import 'package:dio/dio.dart';

import '../../presentation/students/invite_friends_card.dart';
import 'package:BookMyTeacher/presentation/teachers/signIn_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/enums/app_config.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/browser_service.dart';
import '../../services/teacher_api_service.dart';
import '../widgets/verify_account_popup.dart';
import '../widgets/wallet_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardHome extends ConsumerStatefulWidget {
  const DashboardHome({super.key});

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  late Future<Map<String, dynamic>> userCard;
  final List<Map<String, dynamic>> studentReviews = [
    {
      "name": "Aisha Patel",
      "review": "Great teacher! Explained concepts very clearly.",
      "image": "https://i.pravatar.cc/150?img=5",
      "rating": 4.5,
    },
    {
      "name": "Rahul Sharma",
      "review": "Helpful and patient during sessions.",
      "image": "https://i.pravatar.cc/150?img=12",
      "rating": 5.0,
    },
    {
      "name": "Sneha R.",
      "review": "Good teaching but classes sometimes run late.",
      "image": "https://i.pravatar.cc/150?img=8",
      "rating": 3.5,
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  StepStatus _mapStatus(String status) {
    switch (status) {
      case "completed":
        return StepStatus.completed;
      case "inProgress":
        return StepStatus.inProgress;
      default:
        return StepStatus.pending;
    }
  }

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final teacherAsync = ref.watch(userProvider);
    return teacherAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text("Error: $error"))),
      data: (teacher) {
        if (teacher == null) {
          return const Scaffold(
            body: Center(child: Text("No teacher data found")),
          );
        }

        // Convert teacher model to JSON map for easy use
        final teacherData = teacher.toJson();

        // ✅ Safely extract values
        final name = teacherData['name'] ?? 'Unknown';
        final stepsData = teacherData['steps'] as List<dynamic>? ?? [];
        final avatar = teacherData['avatar_url'] ?? "";
        final currentAccountStage =
            teacherData['current_account_stage'] ?? "verification process";
        print(currentAccountStage);
        final accountMsg = teacherData['account_msg'] ?? "";

        final steps = stepsData.map((step) {
          return StepData(
            title: step['title'] ?? '',
            subtitle: step['subtitle'],
            status: _mapStatus(step['status'] ?? 'pending'),
            route: step['route'] ?? '',
            allow: step['allow'] ?? false,
          );
        }).toList();

        // If email not verified → show popup
        if (teacherData['email_verified_at'] == null ||
            teacherData['email_verified_at'] == '') {
          return VerifyAccountPopup(
            onVerified: () async {
              await ref.read(userProvider.notifier).loadUser();
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // 👇 Re-fetch teacher data or refresh provider
            ref.refresh(userProvider.notifier).loadUser(silent: true);
            await Future.delayed(const Duration(seconds: 1)); // optional delay
          },
          color: Colors.green, // optional
          backgroundColor: Colors.transparent, // optional
          // displacement: 50, // optional pull distance
          child: Scaffold(
            body: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(AppConfig.bodyBg, fit: BoxFit.cover),
                ),

                // Main Scrollable Content
                SafeArea(
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage:
                                        (avatar != null && avatar.isNotEmpty)
                                        ? NetworkImage(avatar)
                                        : null, // no background image when avatar is null or empty
                                    child: (avatar == null || avatar.isEmpty)
                                        ? Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.grey[500],
                                          )
                                        : null, // show icon only when no image
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.notifications,
                                  color: Colors.grey[800],
                                ),
                                iconSize: 30,
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            child: WalletSection(),
                          ),
                        ),
                        //
                        const SizedBox(height: 15),
                        const InviteFriendsCard(),
                        const SizedBox(height: 15),
                        //
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 25,
                              left: 10,
                              right: 10,
                              bottom: 20,
                            ),
                            child: Column(
                              children: [
                                if (currentAccountStage != 'account verified')
                                  Column(
                                    children: [
                                      AccountMessageCard(
                                        accountMsg: accountMsg,
                                        steps: steps,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                const TeacherQuickActions(),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 10.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Earnings",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SpendTimeCard(),
                                SizedBox(height: 10),
                                WatchTimeCard(),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Student Reviews",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                            ),
                                            builder: (_) =>
                                                RatingsReviewsSheet(),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                StudentReviewsScrollSection(),
                                SizedBox(height: 10),
                                StudentAchievementCardSection(),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    openWhatsApp(
                                      context,
                                      phone: "917510115544",
                                      message:
                                          "Hello, I want to connect with your team.",
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat_bubble,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 6,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SocialMediaIcons(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

class StepData {
  final String title;
  final String? subtitle;
  final StepStatus status;
  final String route;
  final bool allow;

  StepData({
    required this.title,
    this.subtitle,
    required this.status,
    required this.route,
    required this.allow,
  });
}

enum StepStatus { completed, inProgress, pending }
