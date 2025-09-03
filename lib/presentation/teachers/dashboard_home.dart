import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  // int _currentStep = 3;
  Future<void> _openWhatsApp() async {
    const phoneNumber = "+917510115544";
    const message = "Hello, I want to connect with your team.";

    final url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image for AppBar section
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
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611731.jpg',
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'ASIF T',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: Colors.grey[800],
                              ),
                              iconSize: 30,
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                            ),
                            // Positioned(
                            //   right: 2,
                            //   top: 2,
                            //   child: Container(
                            //     padding: const EdgeInsets.all(4),
                            //     decoration: const BoxDecoration(
                            //       color: Colors.red,
                            //       shape: BoxShape.circle,
                            //     ),
                            //     constraints: const BoxConstraints(
                            //       minWidth: 18,
                            //       minHeight: 18,
                            //     ),
                            //     child: const Text(
                            //       '3',
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //       textAlign: TextAlign.center,
                            //     ),
                            //   ),
                            // ),
                          ],
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

              // Scrollable Body
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
                    padding: const EdgeInsets.only(top:40,bottom: 30,left: 20,right: 20),
                    child: Column(
                      children: [
                        CustomVerticalStepper(
                          steps: [
                            StepData(title: "Personal Info", subtitle: "Completed", status: StepStatus.completed),
                            StepData(title: "Teaching Details", subtitle: "Completed", status: StepStatus.completed),
                            StepData(title: "CV Upload", subtitle: "Completed", status: StepStatus.completed),
                            StepData(title: "Verification Process", subtitle: "In Progress", status: StepStatus.inProgress),
                            StepData(title: "Schedule Interview", status: StepStatus.pending),
                            StepData(title: "Upload Demo Class", status: StepStatus.pending),
                          ],
                        ),
                        SizedBox(height: 20,),
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
                        const SizedBox(height: 20),
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

        return Row(
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
        );
      }),
    );
  }
}

class StepData {
  final String title;
  final String? subtitle;
  final StepStatus status;

  StepData({required this.title, this.subtitle, required this.status});
}

enum StepStatus { completed, inProgress, pending }
