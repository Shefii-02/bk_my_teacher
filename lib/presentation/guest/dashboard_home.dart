import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/browser_service.dart';
import '../../services/guest_api_service.dart';

class DashboardHome extends StatefulWidget {
  final Future<Map<String, dynamic>> guestDataFuture;
  const DashboardHome({super.key, required this.guestDataFuture, required guestId});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<Map<String, dynamic>> _guestDataFuture;

  @override
  void initState() {
    super.initState();
    _guestDataFuture = widget.guestDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _guestDataFuture,
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
            body: Center(child: Text("No guest data found")),
          );
        }

        final guest = snapshot.data!;
        final stepsData = guest['steps'] as List<dynamic>;

        final avatar = guest['avatar'] ?? "https://via.placeholder.com/150";
        final name = guest['user']['name'] ?? "Unknown guest";



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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.check_circle_outline, color: Colors.green),
                            SizedBox(width: 10),
                            Text(
                              'Welcome our guest account',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
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
                            const SizedBox(height: 50),
                            Text("Please stay tuned. Upcoming events and webinars will be shown here.",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,letterSpacing: 1.0)),
                            const SizedBox(height: 50),
                            ElevatedButton.icon(
                              onPressed: () {
                                openWhatsApp(
                                  context,
                                  phone: "917510115544", // no '+'
                                  message: "Hello, I want to connect with your team.",
                                );
                              },
                              icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 6,
                              ),
                            ),
                            const SizedBox(height: 50),


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