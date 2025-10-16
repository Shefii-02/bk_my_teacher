import 'package:BookMyTeacher/presentation/teachers/signIn_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/enums/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/browser_service.dart';
import '../../services/teacher_api_service.dart';

class DashboardHome extends StatefulWidget {
  final Future<Map<String, dynamic>> teacherDataFuture;
  const DashboardHome({
    super.key,
    required this.teacherDataFuture,
    required teacherId,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Map<String, dynamic>> _teacherDataFuture;
  late Future<Map<String, dynamic>> userCard;

  @override
  void initState() {
    super.initState();
    _teacherDataFuture = widget.teacherDataFuture;
    print("************");
    print(_teacherDataFuture);
    print("************");
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _teacherDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("No teacher data found")),
          );
        }

        final teacher = snapshot.data!;
        final stepsData = teacher['steps'] as List<dynamic>;

        final avatar = teacher['avatar'] ?? "https://via.placeholder.com/150";
        final name = teacher['user']['name'] ?? "Unknown Teacher";
        final accountMsg = teacher['account_msg'] ?? "";

        // Convert API steps → StepData
        final steps = stepsData.map((step) {
          return StepData(
            title: step['title'],
            subtitle: step['subtitle'],
            status: _mapStatus(step['status']),
            route: step['route'],
            allow: step['allow'] ?? false,
          );
        }).toList();

        return Scaffold(
          body: Stack(
            children: [
              // SizedBox(
              //   height: 550,
              //   width: double.infinity,
              //   child: Image.network(AppConfig.headerTop, fit: BoxFit.fitWidth),
              // ),
              Container(
                height: 600,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(AppConfig.headerTop),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(avatar),
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
                        const SizedBox(height: 10),
                        if (accountMsg != "")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outlined,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 300,
                                child: Text(
                                  accountMsg,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CustomVerticalStepper(steps: steps),
                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: () {
                                openWhatsApp(
                                  context,
                                  phone: "917510115544", // no '+'
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
                            SizedBox(height: 20),

                            // if (teacher['user']['email_verified_at'] == null)
                            ElevatedButton(
                              onPressed: () async {
                                UserCredential? userCred = await _authService
                                    .verifyWithGoogleFirebase();

                                if (userCred != null) {
                                  final user = userCred.user;
                                  // print(user);
                                  // print("✅ Signed in: ${user?.email}");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Account Verified, ${user?.email}!',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '❌ Account not found. Please sign up normally.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Sign in with Google"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===== Custom Stepper Widget =====
class CustomVerticalStepper extends StatelessWidget {
  final List<StepData> steps;

  const CustomVerticalStepper({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return GestureDetector(
          onTap: step.allow
              ? () {
                  context.go(step.route);
                }
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: step.status == StepStatus.completed
                          ? Colors.green
                          : step.status == StepStatus.inProgress
                          ? Colors.white
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.status == StepStatus.inProgress
                            ? Colors.grey
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: step.status == StepStatus.completed
                          ? Colors.green
                          : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: step.allow ? Colors.black : Colors.grey,
                            ),
                          ),
                          if (step.allow == true)
                            Icon(
                              // step.status == StepStatus.completed
                              //     ?
                              Icons.edit_rounded,
                                  // : Icons.rotate_right,
                              color: step.status == StepStatus.completed
                                  ? Colors.green
                                  : step.status == StepStatus.inProgress
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 14,
                            ),
                        ],
                      ),

                          if (step.subtitle != null)
                            SizedBox(
                              width:300,
                              child: Text(
                                step.subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: step.status == StepStatus.completed
                                      ? Colors.green
                                      : step.status == StepStatus.inProgress
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                                softWrap: false,
                              ),
                            ),



                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
