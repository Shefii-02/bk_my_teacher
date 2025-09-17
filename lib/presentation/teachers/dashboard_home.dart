import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/teacher_api_service.dart';

class DashboardHome extends StatefulWidget {
  final String teacherData; // teacherId
  const DashboardHome({super.key, required this.teacherData});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Map<String, dynamic>> _teacherDataFuture;

  @override
  void initState() {
    super.initState();
    _teacherDataFuture = _fetchTeacherData();
  }

  Future<Map<String, dynamic>> _fetchTeacherData() async {
    final api = TeacherApiService();
    return await api.fetchTeacherData(widget.teacherData); // must return {teacher, steps}
  }

  // WhatsApp
  Future<void> _openWhatsApp() async {
    const phoneNumber = "+917510115544";
    const message = "Hello, I want to connect with your team.";
    final url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

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
        final name = teacher['name'] ?? "Unknown Teacher";

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
              Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background/full-bg.jpg'),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outlined, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text(
                              'Your account waiting for verification',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              onPressed: _openWhatsApp,
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
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: step.allow ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (step.subtitle != null)
                        Text(
                          step.subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: step.status == StepStatus.completed
                                ? Colors.green
                                : step.status == StepStatus.inProgress
                                ? Colors.blue
                                : Colors.grey,
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
