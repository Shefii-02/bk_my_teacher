import 'dart:ui';
import 'package:BookMyTeacher/presentation/teachers/account_message_card.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/achievements_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/rating_reviews.dart';
import 'package:BookMyTeacher/presentation/teachers/quick_action/watch_time_sheet.dart';
import 'package:BookMyTeacher/presentation/teachers/spend_time_card.dart';
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Dedications & Achievements",
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
                                                AchievementsSheet(),
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
                                _buildLevelCard(),
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

  Widget _buildLevelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LevelStatusBadge(level: 2, pointsRemaining: 500),
          const SizedBox(height: 15),

          GoldProgressBar(progress: 0.7),
          const SizedBox(height: 8),
        ],
      ),
    );
    // }
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

class GoldProgressBar extends StatelessWidget {
  final double progress; // from 0.0 to 1.0
  final int leftValue;
  final int rightValue;
  final String centerText;

  const GoldProgressBar({
    super.key,
    required this.progress,
    this.leftValue = 2,
    this.rightValue = 3,
    this.centerText = '5200/6000',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blurred background glow
        ClipRRect(
          borderRadius: BorderRadius.circular(130),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3B14E), Color(0xFFFFCE51)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(130),
              ),
            ),
          ),
        ),

        // Gold flat progress bar
        Container(
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(90),
          ),
          child: Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(90),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF3B14E), Color(0xFFFFCE51)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Left circle + number
        Positioned(
          left: 30,
          child: Row(
            children: [
              _goldCircle(),
              const SizedBox(width: 4),
              Text(
                '$leftValue',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.8,
                  color: Color(0xFF825C24),
                ),
              ),
            ],
          ),
        ),

        // Center text
        Text(
          centerText,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14.8,
            color: Color(0xFF685613),
            letterSpacing: 0.025,
          ),
        ),

        // Right circle + trophy + number
        Positioned(
          right: 30,
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFF825C24),
                size: 16,
              ),
              const SizedBox(width: 4),
              _goldCircle(),
              const SizedBox(width: 4),
              Text(
                '$rightValue',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.8,
                  color: Color(0xFF825C24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _goldCircle() {
    return Container(
      width: 18, // slightly larger for border
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // border color
      ),
      child: Center(
        child: Container(
          width: 17,
          height: 17,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFF3B14E), Color(0xFFFFCE51)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

class LevelStatusBadge extends StatelessWidget {
  final int level;
  final int pointsRemaining;
  final IconData icon;

  const LevelStatusBadge({
    super.key,
    this.level = 2,
    this.pointsRemaining = 500,
    this.icon = Icons.emoji_events, // trophy icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left dark circular background with trophy
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A0F24),
                  border: Border.all(
                    color: const Color(0xFF3B4043),
                    width: 2.4,
                  ),
                ),
              ),
              Positioned(
                top: 6, // adds a small gap between icon and number
                child: Icon(icon, size: 22, color: const Color(0xFFFFDD64)),
              ),

              // Gradient text "2"
              Positioned(
                bottom: 2, // adds a small gap between icon and number
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color.fromRGBO(253, 253, 253, 0.97),
                      Color(0xFFFFDD64),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    "$level",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 15),

          // Right side texts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level $level',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 21,
                  letterSpacing: -0.37,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$pointsRemaining Points to next level',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.8,
                  letterSpacing: 0.02,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
