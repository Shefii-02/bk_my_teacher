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

        // return Scaffold(
        //   body: Stack(
        //     children: [
        //       // SizedBox(
        //       //   height: 550,
        //       //   width: double.infinity,
        //       //   child: Image.network(AppConfig.headerTop, fit: BoxFit.fitWidth),
        //       // ),
        //       Container(
        //         height: 600,
        //         width: double.infinity,
        //         decoration: const BoxDecoration(
        //           image: DecorationImage(
        //             image: NetworkImage(AppConfig.headerTop),
        //             fit: BoxFit.fill,
        //           ),
        //         ),
        //       ),
        //       Column(
        //         children: [
        //           const SizedBox(height: 60),
        //           Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 16),
        //             child: Column(
        //               children: [
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     Row(
        //                       children: [
        //                         CircleAvatar(
        //                           radius: 25,
        //                           backgroundImage: NetworkImage(avatar),
        //                         ),
        //                         const SizedBox(width: 10),
        //                         Text(
        //                           name,
        //                           style: const TextStyle(
        //                             color: Colors.black,
        //                             fontWeight: FontWeight.bold,
        //                             fontSize: 18.0,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     IconButton(
        //                       icon: Icon(
        //                         Icons.notifications,
        //                         color: Colors.grey[800],
        //                       ),
        //                       iconSize: 30,
        //                       padding: EdgeInsets.zero,
        //                       onPressed: () {},
        //                     ),
        //                   ],
        //                 ),
        //                 const SizedBox(height: 10),
        //                 if (accountMsg != "")
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.start,
        //                     children: [
        //                       const Icon(
        //                         Icons.info_outlined,
        //                         color: Colors.redAccent,
        //                       ),
        //                       const SizedBox(width: 10),
        //                       SizedBox(
        //                         width: 300,
        //                         child: Text(
        //                           accountMsg,
        //                           style: const TextStyle(
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                           overflow: TextOverflow.ellipsis,
        //                           maxLines: 5,
        //                           softWrap: false,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //               ],
        //             ),
        //           ),
        //           const SizedBox(height: 10),
        //           Expanded(
        //             child: Container(
        //               width: double.infinity,
        //               decoration: const BoxDecoration(
        //                 color: Colors.white,
        //                 borderRadius: BorderRadius.only(
        //                   topLeft: Radius.circular(30),
        //                   topRight: Radius.circular(30),
        //                 ),
        //                 boxShadow: [
        //                   BoxShadow(
        //                     color: Colors.black12,
        //                     blurRadius: 10,
        //                     offset: Offset(0, -2),
        //                   ),
        //                 ],
        //               ),
        //               child: SingleChildScrollView(
        //                 padding: const EdgeInsets.all(20),
        //                 child: Column(
        //                   children: [
        //                     CustomVerticalStepper(steps: steps),
        //                     const SizedBox(height: 20),
        //
        //                     ElevatedButton.icon(
        //                       onPressed: () {
        //                         openWhatsApp(
        //                           context,
        //                           phone: "917510115544", // no '+'
        //                           message:
        //                               "Hello, I want to connect with your team.",
        //                         );
        //                       },
        //                       icon: const Icon(
        //                         Icons.chat_bubble,
        //                         color: Colors.white,
        //                         size: 20,
        //                       ),
        //                       label: const Text(
        //                         "Connect With Our Team",
        //                         style: TextStyle(
        //                           fontSize: 15,
        //                           fontWeight: FontWeight.bold,
        //                           color: Colors.white,
        //                         ),
        //                       ),
        //                       style: ElevatedButton.styleFrom(
        //                         backgroundColor: const Color(0xFF25D366),
        //                         padding: const EdgeInsets.symmetric(
        //                           horizontal: 24,
        //                           vertical: 14,
        //                         ),
        //                         shape: RoundedRectangleBorder(
        //                           borderRadius: BorderRadius.circular(30),
        //                         ),
        //                         elevation: 6,
        //                       ),
        //                     ),
        //                     SizedBox(height: 20),
        //
        //                     // if (teacher['user']['email_verified_at'] == null)
        //                     ElevatedButton(
        //                       onPressed: () async {
        //                         UserCredential? userCred = await _authService
        //                             .verifyWithGoogleFirebase();
        //
        //                         if (userCred != null) {
        //                           final user = userCred.user;
        //                           // print(user);
        //                           // print("✅ Signed in: ${user?.email}");
        //                           ScaffoldMessenger.of(context).showSnackBar(
        //                             SnackBar(
        //                               content: Text(
        //                                 'Account Verified, ${user?.email}!',
        //                               ),
        //                             ),
        //                           );
        //                         } else {
        //                           ScaffoldMessenger.of(context).showSnackBar(
        //                             SnackBar(
        //                               content: Text(
        //                                 '❌ Account not found. Please sign up normally.',
        //                               ),
        //                             ),
        //                           );
        //                         }
        //                       },
        //                       child: const Text("Sign in with Google"),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // );
       // return Scaffold(
       //    backgroundColor: const Color(0xFFF0F5F2), // Light green background
       //    body: CustomScrollView(
       //      slivers: [
       //        SliverAppBar(
       //          expandedHeight: 200.0,
       //          floating: false,
       //          pinned: true,
       //          backgroundColor: Colors.transparent,
       //          flexibleSpace: FlexibleSpaceBar(
       //            background: Container(
       //              decoration: const BoxDecoration(
       //                gradient: LinearGradient(
       //                  colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)], // Green gradient
       //                  begin: Alignment.topLeft,
       //                  end: Alignment.bottomRight,
       //                ),
       //                borderRadius: BorderRadius.only(
       //                  bottomLeft: Radius.circular(30),
       //                  bottomRight: Radius.circular(30),
       //                ),
       //              ),
       //              child: SafeArea(
       //                child: Padding(
       //                  padding: const EdgeInsets.all(16.0),
       //                  child: Column(
       //                    crossAxisAlignment: CrossAxisAlignment.start,
       //                    children: [
       //                      Row(
       //                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
       //                        children: [
       //                          Row(
       //                            children: [
       //                              const CircleAvatar(
       //                                radius: 25,
       //                                backgroundImage: NetworkImage(
       //                                    'https://via.placeholder.com/150'), // Replace with actual image
       //                              ),
       //                              const SizedBox(width: 10),
       //                              Column(
       //                                crossAxisAlignment: CrossAxisAlignment.start,
       //                                children: const [
       //                                  Text(
       //                                    'ASIF T',
       //                                    style: TextStyle(
       //                                      color: Colors.white,
       //                                      fontSize: 20,
       //                                      fontWeight: FontWeight.bold,
       //                                    ),
       //                                  ),
       //                                ],
       //                              ),
       //                            ],
       //                          ),
       //                          Stack(
       //                            children: [
       //                              const Icon(
       //                                Icons.notifications,
       //                                color: Colors.white,
       //                                size: 30,
       //                              ),
       //                              Positioned(
       //                                right: 0,
       //                                child: Container(
       //                                  padding: const EdgeInsets.all(1),
       //                                  decoration: BoxDecoration(
       //                                    color: Colors.red,
       //                                    borderRadius: BorderRadius.circular(6),
       //                                  ),
       //                                  constraints: const BoxConstraints(
       //                                    minWidth: 12,
       //                                    minHeight: 12,
       //                                  ),
       //                                  child: const Text(
       //                                    '5',
       //                                    style: TextStyle(
       //                                      color: Colors.white,
       //                                      fontSize: 8,
       //                                    ),
       //                                    textAlign: TextAlign.center,
       //                                  ),
       //                                ),
       //                              )
       //                            ],
       //                          ),
       //                        ],
       //                      ),
       //                      const SizedBox(height: 20),
       //                      Row(
       //                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
       //                        children: [
       //                          const Text(
       //                            'My Wallet',
       //                            style: TextStyle(
       //                              color: Colors.white70,
       //                              fontSize: 16,
       //                            ),
       //                          ),
       //                          GestureDetector(
       //                            onTap: () {
       //                              // Handle view wallet tap
       //                            },
       //                            child: Row(
       //                              children: const [
       //                                Text(
       //                                  'View My Wallet',
       //                                  style: TextStyle(
       //                                    color: Colors.white,
       //                                    fontSize: 16,
       //                                    fontWeight: FontWeight.bold,
       //                                  ),
       //                                ),
       //                                Icon(
       //                                  Icons.arrow_forward_ios,
       //                                  color: Colors.white,
       //                                  size: 16,
       //                                ),
       //                              ],
       //                            ),
       //                          ),
       //                        ],
       //                      ),
       //                      const SizedBox(height: 10),
       //                      Row(
       //                        mainAxisAlignment: MainAxisAlignment.spaceAround,
       //                        children: [
       //                          _buildWalletCard(
       //                              'GreenCoins', '100', Colors.greenAccent, Icons.money),
       //                          _buildWalletCard(
       //                              'Rupees', '100', Colors.amber, Icons.currency_rupee),
       //                        ],
       //                      ),
       //                    ],
       //                  ),
       //                ),
       //              ),
       //            ),
       //          ),
       //        ),
       //        SliverList(
       //          delegate: SliverChildListDelegate(
       //            [
       //              Padding(
       //                padding: const EdgeInsets.all(16.0),
       //                child: Column(
       //                  crossAxisAlignment: CrossAxisAlignment.start,
       //                  children: [
       //                    _buildInviteFriendsCard(),
       //                    const SizedBox(height: 20),
       //                    _buildProgressCard(),
       //                    const SizedBox(height: 20),
       //                    _buildQuickActions(),
       //                    const SizedBox(height: 20),
       //                    _buildSectionHeader('Earnings'),
       //                    _buildEarningItem('Spend-time', 'Individual Class\'s', '35.45', 0.7),
       //                    _buildEarningItem('Spend-time', 'Own Course Class\'s', '35.45', 0.5),
       //                    _buildEarningItem('Spend-time', 'Youtube Class\'s', '35.45', 0.9),
       //                    const SizedBox(height: 20),
       //                    _buildSectionHeader('Watch-time'),
       //                    _buildWatchTimeItem('Individual Class\'s', '35.45'),
       //                    _buildWatchTimeItem('Own Course Class\'s', '35.45'),
       //                    _buildWatchTimeItem('Youtube Class\'s', '35.45'),
       //                    const SizedBox(height: 20),
       //                    _buildSectionHeader('Students Reviews'),
       //                    _buildStudentReview(
       //                      'Jack sparrow',
       //                      'If your class section is full and exams are approaching, prioritize effective study strategies and time management to maximize your preparation.',
       //                    ),
       //                    const SizedBox(height: 20),
       //                    _buildSectionHeader('Dedications & Achivements'),
       //                    _buildLevelCard(),
       //                  ],
       //                ),
       //              ),
       //            ],
       //          ),
       //        ),
       //      ],
       //    )
       //  );
        return Scaffold(
          backgroundColor: const Color(0xFFF0F5F2), // Light green background
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350.0, // Increased height for the top section
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8BC34A), Color(0xFF4CAF50)], // Green gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                          'https://via.placeholder.com/150'), // Replace with actual image
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Jone Luka',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 12,
                                          minHeight: 12,
                                        ),
                                        child: const Text(
                                          '5',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'TIP FOR',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        'SCORING ALL EXAMS',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      '95+',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'TIP',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.search, color: Colors.grey),
                                  hintText: 'Searching for your teacher or subject...',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  suffixIcon:
                                  Icon(Icons.filter_list, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildRequestClassSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWalletSection(),
                          const SizedBox(height: 20),
                          _buildInviteFriendsCard(),
                          const SizedBox(height: 20),
                          _buildTopTeachersSection(),
                          const SizedBox(height: 20),
                          _buildProvidingSubjectsSection(),
                          const SizedBox(height: 20),
                          _buildProvidingCoursesSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teachers'),
              BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Courses'),
              BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'My Class'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      }
    );
  }


  Widget _buildRequestClassSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request a class/course',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRequestOption('View full Syllabus', Icons.book),
              _buildRequestOption('Grades', Icons.school),
              _buildRequestOption('Requested class\'s', Icons.history),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRequestOption('Board/Syllabus', Icons.menu_book),
              _buildRequestOption('Subjects', Icons.library_books),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Do you want tell something...',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Handle book demo class tap
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Book Demo Class'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestOption(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Wallet',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle view wallet tap
              },
              child: Row(
                children: const [
                  Text(
                    'View My Wallet',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWalletCard(
                'GreenCoins', '100', Colors.greenAccent, Icons.money),
            _buildWalletCard(
                'Rupees', '100', Colors.amber, Icons.currency_rupee),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCard(String title, String amount, Color color, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _buildInviteFriendsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.green),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              'Invite friends and earn rewards!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle refer now tap
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Refer Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTeachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Rating Teachers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTeacherCard(
                'ASIF T',
                'NET Qualified',
                'MSc. in English',
                '5.0',
                'https://via.placeholder.com/150', // Replace
              ),
              _buildTeacherCard(
                'RAMYA M',
                'NET Qualified',
                'MSc. in English',
                '5.0',
                'https://via.placeholder.com/150', // Replace
              ),
              _buildTeacherCard(
                'NITHYA',
                'NET Qualified',
                'MSc. in English',
                '5.0',
                'https://via.placeholder.com/150', // Replace
              ),
              _buildTeacherCard(
                'RENJITH',
                'NET Qualified',
                'MSc. in English',
                '5.0',
                'https://via.placeholder.com/150', // Replace
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherCard(String name, String qualification1,
      String qualification2, String rating, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            qualification1,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            qualification2,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' student Rating',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProvidingSubjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'We\'re Providing Subjects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildSubjectTag('English'),
            _buildSubjectTag('Hindi'),
            _buildSubjectTag('English'),
            _buildSubjectTag('English'),
            _buildSubjectTag('English'),
            _buildSubjectTag('English'),
            _buildSubjectTag('English'),
            _buildSubjectTag('English'),
            _buildSubjectTag('English'),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectTag(String subject) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.book_outlined, color: Colors.grey, size: 18),
          const SizedBox(width: 5),
          Text(subject, style: const TextStyle(fontSize: 14)),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }

  Widget _buildProvidingCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'We\'re providing trending courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCourseCard(
                'https://via.placeholder.com/150', // Replace
                'SPEAK ENGLISH LIKE AN EXPERT',
                'www.website.com',
              ),
              _buildCourseCard(
                'https://via.placeholder.com/150', // Replace
                'SPANISH FOR BEGINNERS',
                'www.website.com',
              ),
              _buildCourseCard(
                'https://via.placeholder.com/150', // Replace
                'FRENCH ESSENTIALS',
                'www.website.com',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(String imageUrl, String title, String subtitle) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // Widget _buildWalletCard(String title, String amount, Color color, IconData icon) {
  //   return Container(
  //     width: 150,
  //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.2),
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Icon(icon, color: color, size: 30),
  //         const SizedBox(width: 10),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               amount,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             Text(
  //               title,
  //               style: const TextStyle(
  //                 color: Colors.white70,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildInviteFriendsCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.green.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: const Icon(Icons.card_giftcard, color: Colors.green),
  //         ),
  //         const SizedBox(width: 15),
  //         const Expanded(
  //           child: Text(
  //             'Invite friends and earn rewards!',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             // Handle refer now tap
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.green,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //           child: const Text('Refer Now'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your application is in progress. We will notify you once the next step is available',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(Icons.bar_chart, 'Statistics'),
        _buildActionButton(Icons.calendar_today, 'My Schedules'),
        _buildActionButton(Icons.collections_bookmark, 'Own Courses'),
        _buildActionButton(Icons.star_border, 'Rating'),
        _buildActionButton(Icons.emoji_events, 'Achievements'),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.green, size: 30),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _buildEarningItem(
      String category, String title, String amount, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple), // Example color
                ),
              ),
              const Icon(Icons.school, color: Colors.purple, size: 20), // Example icon
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _buildWatchTimeItem(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.watch_later_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _buildStudentReview(String name, String review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                '2',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level 2',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '500 Points to next level',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 5200 / 6000, // Example progress
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '2',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '5200/6000',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                '3',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
    // }

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
