import 'dart:ui';
import 'package:BookMyTeacher/core/constants/image_paths.dart';
import 'package:BookMyTeacher/presentation/chating/screens/chat_list_screen.dart';
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
import 'package:hive/hive.dart';
import '../chat/screens/chat_home_screen_dummy.dart';
import '../components/app_reviews.dart';
import '../widgets/merchant_app_phonepe.dart';
import '../../presentation/students/invite_friends_card.dart';
import 'package:BookMyTeacher/presentation/teachers/signIn_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/enums/app_config.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/browser_service.dart';
import '../../services/teacher_api_service.dart';
import '../widgets/bodyBg.dart';
import '../widgets/connect_with_team_whatsapp.dart';
import '../widgets/notification_bell.dart';
import '../widgets/today_classes_section.dart';
import '../widgets/top_banner_carousel.dart';
import '../widgets/unified_payment_page.dart';
import '../widgets/verify_account_popup.dart';
import '../widgets/wallet_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardHome extends ConsumerStatefulWidget {
  const DashboardHome({super.key});

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  late Future<Map<String, dynamic>> userCard;

  int unreadCount = 0;
  String token = '';

  @override
  void initState() {
    super.initState();
    _initialize();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    // Permission.camera, Permission.microphone, Permission.contacts,
    await [Permission.manageExternalStorage, Permission.storage].request();
  }

  Future<void> _initialize() async {
    final box = await Hive.openBox('app_storage');
    token = box.get('auth_token');
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
        final id = teacherData['id'] ?? 'Unknown';

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
                Positioned.fill(child: BodyBg()),
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
                              Container(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome Back',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      name.length > 15
                                          ? "${name.substring(0, 15)}.."
                                          : name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                      ),
                                    ),


                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  NotificationBell(
                                    onTap: () =>
                                        showNotificationsSheet(context, ref),
                                  ),
                                  // dynamic value from API
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatListScreen(
                                                userId: id,
                                                token: token,
                                              ),
                                              // ChatHomeScreenDummy(),
                                          // ChatHomeScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      elevation: 1,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Chat"),
                                        SizedBox(width: 8),

                                        /// ICON + BADGE
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Icon(Icons.chat_outlined),
                                            if (unreadCount > 0)
                                              Positioned(
                                                right: -10,
                                                top: -15,
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  constraints: BoxConstraints(
                                                    minWidth: 18,
                                                    minHeight: 18,
                                                  ),
                                                  child: Text(
                                                    unreadCount > 99
                                                        ? "99+"
                                                        : unreadCount
                                                              .toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),

                              // Row(
                              //   children: [
                              // CircleAvatar(
                              //   radius: 25,
                              //   backgroundColor: Colors.grey[200],
                              //   backgroundImage:
                              //       (avatar != null && avatar.isNotEmpty)
                              //       ? NetworkImage(avatar)
                              //       : null, // no background image when avatar is null or empty
                              //   child: (avatar == null || avatar.isEmpty)
                              //       ? Icon(
                              //           Icons.person,
                              //           size: 30,
                              //           color: Colors.grey[500],
                              //         )
                              //       : null, // show icon only when no image
                              // ),

                              // Text(
                              //   name,
                              //   style: const TextStyle(
                              //     color: Colors.black,
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 18.0,
                              //   ),
                              // ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        TopBannerCarousel(),
                        const SizedBox(height: 10),
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
                        // ---------- Today's Classes Section ----------
                        TodayClassesSection(),
                        const SizedBox(height: 20),
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
                                        "The Results Speak for Themselves",
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
                                ConnectWithTeamWhatsapp(),
                                const SizedBox(height: 30),
                                SocialMediaIcons(),
                                const SizedBox(height: 20),
                                const AppReviews(),
                                const SizedBox(height: 20),
                                // InkWell(
                                //   onTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (_) =>
                                //             // const UnifiedPaymentPage(),
                                //         const CheckoutPage(),
                                //       ),
                                //     );
                                //   },
                                //   child: Container(
                                //     width: 150,
                                //     height: 50,
                                //     decoration: BoxDecoration(
                                //       color: Colors.green,
                                //       borderRadius: BorderRadius.circular(12),
                                //     ),
                                //     child: const Center(
                                //       child: Text(
                                //         "Pay ₹20",
                                //         style: TextStyle(
                                //           fontSize: 24,
                                //           color: Colors.white,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
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

  Widget notificationIcon(int count, VoidCallback onTap) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.grey[800], size: 30),
          onPressed: onTap,
        ),

        if (count > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  void showNotificationsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final asyncData = ref.watch(notificationProvider);

        return asyncData.when(
          data: (data) {
            final list = data.notifications;

            if (list.isEmpty) {
              return const Center(child: Text("No notifications"));
            }

            return ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, index) {
                final item = list[index];

                return ListTile(
                  leading: Icon(
                    Icons.notifications_active_rounded,
                    color: item.isRead ? Colors.grey : Colors.black,
                  ),

                  /// TITLE + SUBTITLE MERGED
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: item.isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isRead
                              ? Colors.grey[600]
                              : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  /// RIGHT SIDE INFO BUTTON
                  trailing: IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: item.isRead ? Colors.grey : Colors.black,
                    ),
                    onPressed: () async {
                      /// Mark as read
                      await ref.read(
                        markNotificationReadProvider(item.id).future,
                      );

                      /// Refresh list
                      ref.refresh(notificationProvider);

                      /// Open details popup
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.message,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Time: ${item.time}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Close"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text("Failed to load notifications")),
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
