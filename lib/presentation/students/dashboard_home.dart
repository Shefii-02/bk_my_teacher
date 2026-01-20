import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/presentation/students/course_sections.dart';
import 'package:BookMyTeacher/presentation/students/request_form.dart';
import 'package:BookMyTeacher/presentation/students/subject_carousel.dart';

import 'package:BookMyTeacher/presentation/students/teacher_carousel_two.dart';

import 'package:BookMyTeacher/presentation/widgets/connect_with_team.dart';
import 'package:BookMyTeacher/presentation/widgets/social_media_icons.dart';
import 'package:BookMyTeacher/presentation/widgets/unified_payment_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';

import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/image_paths.dart';
import '../../firebase_options.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/merchant_app_phonepe.dart';
import '../widgets/notification_bell.dart';
import '../widgets/top_banner_carousel.dart';

import '../widgets/verify_account_popup.dart';
import '../widgets/wallet_section.dart';
import 'invite_friends_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardHome extends ConsumerStatefulWidget {
  const DashboardHome({super.key});

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
    _initialize();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isInitialized = true;
    } catch (e) {
      print("Google Sign-In init failed: $e");
    }
  }

  Future<void> requestPermissions() async {
    // Permission.camera, Permission.microphone, Permission.contacts,
    await [Permission.manageExternalStorage, Permission.storage].request();
  }

  bool showRequestForm = false;
  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(userProvider);
    return studentAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text("Error: $error"))),
      data: (student) {
        if (student == null) {
          return const Scaffold(
            body: Center(child: Text("No student data found")),
          );
        }

        // Convert student model to JSON map for easy use
        final studentData = student.toJson();

        // ✅ Safely extract values
        final name = studentData['name'] ?? 'Unknown';
        final avatar = studentData['avatar_url'] ?? "";

        // If email not verified → show popup
        if (studentData['email_verified_at'] == null ||
            studentData['email_verified_at'] == '') {
          return VerifyAccountPopup(
            onVerified: () async {
              await ref.read(userProvider.notifier).loadUser();
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // 👇 Re-fetch student data or refresh provider
            ref.refresh(userProvider.notifier).loadUser(silent: true);
            await Future.delayed(const Duration(seconds: 1)); // optional delay
          },
          color: Colors.green, // optional
          backgroundColor: Colors.transparent, // optional
          // displacement: 50, // optional pull distance
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImagePaths.appBg),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    // padding:
                    // const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // ---------- Header ----------
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage:
                                        (avatar != null && avatar.isNotEmpty)
                                        ? NetworkImage(avatar)
                                        : null, // no background image when avatar is null or empty
                                    child: (avatar == null || avatar.isEmpty)
                                        ? Icon(
                                            Icons.person,
                                            size: 25,
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
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                              NotificationBell(
                                onTap: () =>
                                    showNotificationsSheet(context, ref),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 10),
                        TopBannerCarousel(),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          // padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),

                              // 🔘 Request a Class Button
                              Center(
                                child: NeoPopTiltedButton(
                                  isFloating: true,
                                  onTapUp: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (context) {
                                        return const RequestFormBottomSheet();
                                      },
                                    );
                                  },
                                  decoration:
                                      const NeoPopTiltedButtonDecoration(
                                        color: Color(0xFF70E183),
                                        plunkColor: Color(0xFFE8F9E8),
                                        shadowColor: Color(0xFF2A3B2A),
                                        showShimmer: true,
                                      ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 70.0,
                                      vertical: 15,
                                    ),
                                    child: Text(
                                      'Request a Class/Course',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ---------- Request Class Section ----------
                              // RequestForm(),
                              const SizedBox(height: 20),
                              InviteFriendsCard(),
                              const SizedBox(height: 20),

                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     left: 12.0,
                              //     right: 12.0,
                              //   ),
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       color: const Color(0x52B0FFDF),
                              //       borderRadius: BorderRadius.circular(20),
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.green.withOpacity(
                              //               0.2),
                              //           blurRadius: 12,
                              //           offset: const Offset(0, 6),
                              //         ),
                              //       ],
                              //     ),
                              //     padding: const EdgeInsets.symmetric(
                              //         vertical: 25),
                              //     child: WalletSection(),
                              //   ),
                              // ),
                              const SizedBox(height: 20),
                              // ---------- Top Teachers ----------
                              const Text(
                                'Learn from the Best Teachers Around You',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TeacherCarouselTwoRows(),
                              const Text(
                                'Academics A - Z Index',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // ---------- Providing Subjects ----------
                              SubjectCarousel(),
                              const SizedBox(height: 40),
                              // ---------- Providing Courses ----------
                              const Text(
                                'Discover Courses That Fit Your Goals',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 30),
                              CourseSections(),
                              const SizedBox(height: 40),
                              SocialMediaIcons(),
                              const SizedBox(height: 40),
                              ConnectWithTeam(),
                              const SizedBox(height: 20),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (_) =>
                              //             // const UnifiedPaymentPage(),
                              //         const MerchantApp(),
                              //       ),
                              //     );
                              //   },
                              //   child: Container(
                              //     width: 200,
                              //     height: 200,
                              //     decoration: BoxDecoration(
                              //       color: Colors.blue,
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

  Widget _buildProvidingSubjectsSection() =>
      _buildChipSection('Providing Subjects');
  Widget _buildProvidingCoursesSection() =>
      _buildChipSection('Providing Courses');

  Widget _buildChipSection(String title) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            6,
            (index) => Chip(
              label: Text('$title ${index + 1}'),
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          ),
        ),
      ],
    ),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 5),
    ],
  );

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

class RequestFormBottomSheet extends StatelessWidget {
  const RequestFormBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            Center(
              child: const Text(
                "Request a Class/Course",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            const RequestForm(),
          ],
        ),
      ),
    );
  }
}
