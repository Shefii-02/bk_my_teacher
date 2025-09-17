import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/launch_status_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required Map<String, dynamic> teacherData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Simulated JSON string
    const String jsonData = '''
    [
      { "icon": "book_outlined", "count": "12", "title": "Reviews" },
      { "icon": "people_outline", "count": "24", "title": "Rating" },
      { "icon": "video_camera_front_outlined", "count": "5", "title": "Course" },
      { "icon": "star_border", "count": "18", "title": "Reviews" }
    ]
    ''';

    // Decode JSON to list
    final List<dynamic> gridItems = json.decode(jsonData);

    // Map string to IconData
    final Map<String, IconData> iconMap = {
      "book_outlined": Icons.book_outlined,
      "people_outline": Icons.people_outline,
      "video_camera_front_outlined": Icons.video_camera_front_outlined,
      "star_border": Icons.star_border,
      "assignment_outlined": Icons.assignment_outlined,
      "payment_outlined": Icons.payment_outlined,
    };

    Future<void> _logout(BuildContext context) async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Logout"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await LaunchStatusService.resetApp();

        context.go('/auth');
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: 300,
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
              // Top Section (Profile and Back/Settings buttons)
              SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_left_sharp,
                                color: Colors.black,
                                weight: 800,
                              ),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              onPressed: () => context.go('/teacher-dashboard'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.black87,
                            ),
                            onPressed: () async {
                              final RenderBox button =
                                  context.findRenderObject() as RenderBox;
                              final RenderBox overlay =
                                  Overlay.of(context).context.findRenderObject()
                                      as RenderBox;

                              final RelativeRect position =
                                  RelativeRect.fromRect(
                                    Rect.fromPoints(
                                      button.localToGlobal(
                                        Offset.zero,
                                        ancestor: overlay,
                                      ),
                                      button.localToGlobal(
                                        button.size.bottomRight(Offset.zero),
                                        ancestor: overlay,
                                      ),
                                    ),
                                    Offset.zero & overlay.size,
                                  );

                              final selected = await showMenu<String>(
                                context: context,
                                position: position,
                                items: [
                                  // const PopupMenuItem<String>(
                                  //   value: "profile",
                                  //   child: Row(
                                  //     children: [
                                  //       Icon(
                                  //         Icons.person_outline,
                                  //         color: Colors.black87,
                                  //       ),
                                  //       SizedBox(width: 10),
                                  //       Text("Profile"),
                                  //     ],
                                  //   ),
                                  // ),
                                  const PopupMenuItem<String>(
                                    value: "logout",
                                    child: Row(
                                      children: [
                                        Icon(Icons.logout, color: Colors.red),
                                        SizedBox(width: 10),
                                        Text("Logout"),
                                      ],
                                    ),
                                  ),
                                ],
                              );

                              if (selected == "logout") {
                                _logout(context);
                              } else if (selected == "profile") {
                                Navigator.pushNamed(context, '/profile');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611731.jpg',
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Welcome to BookMyTeacher',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
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
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 40,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Card(
                        //       elevation: 10,
                        //       shadowColor: Colors.blueAccent.withOpacity(0.3),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Container(
                        //         width: 165,
                        //         height: 110,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(20),
                        //           gradient: LinearGradient(
                        //             colors: [Colors.white, Colors.white],
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //           ),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(16.0),
                        //           child: Row(
                        //             crossAxisAlignment: CrossAxisAlignment.center,
                        //             children: [
                        //               // Avatar
                        //               CircleAvatar(
                        //                 radius: 28,
                        //                 backgroundColor: Colors.white,
                        //                 child: CircleAvatar(
                        //                   radius: 25,
                        //                   backgroundImage: NetworkImage(
                        //                     'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611731.jpg',
                        //                   ),
                        //                 ),
                        //               ),
                        //               const SizedBox(width: 16),
                        //
                        //               // Text content
                        //               Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: const [
                        //                   Text(
                        //                     '5',
                        //                     style: TextStyle(
                        //                       fontSize: 24,
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: 4),
                        //                   Text(
                        //                     'Data',
                        //                     style: TextStyle(
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     Card(
                        //       elevation: 10,
                        //       shadowColor: Colors.blueAccent.withOpacity(0.3),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Container(
                        //         width: 165,
                        //         height: 110,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(20),
                        //           gradient: LinearGradient(
                        //             colors: [Colors.white, Colors.white],
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //           ),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(16.0),
                        //           child: Row(
                        //             crossAxisAlignment: CrossAxisAlignment.center,
                        //             children: [
                        //               // Avatar
                        //               CircleAvatar(
                        //                 radius: 28,
                        //                 backgroundColor: Colors.white,
                        //                 child: CircleAvatar(
                        //                   radius: 25,
                        //                   backgroundImage: NetworkImage(
                        //                     'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611731.jpg',
                        //                   ),
                        //                 ),
                        //               ),
                        //               const SizedBox(width: 16),
                        //
                        //               // Text content
                        //               Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: const [
                        //                   Text(
                        //                     '5',
                        //                     style: TextStyle(
                        //                       fontSize: 24,
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: 4),
                        //                   Text(
                        //                     'Data',
                        //                     style: TextStyle(
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //
                        //   ],
                        // ),
                        // SizedBox(height: 10,),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Card(
                        //       elevation: 10,
                        //       shadowColor: Colors.blueAccent.withOpacity(0.3),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Container(
                        //         width: 165,
                        //         height: 110,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(20),
                        //           gradient: LinearGradient(
                        //             colors: [Colors.white, Colors.white],
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //           ),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(16.0),
                        //           child: Row(
                        //             crossAxisAlignment: CrossAxisAlignment.center,
                        //             children: [
                        //               // Avatar
                        //               CircleAvatar(
                        //                 radius: 28,
                        //                 backgroundColor: Colors.white,
                        //                 child: CircleAvatar(
                        //                   radius: 25,
                        //                   backgroundImage: NetworkImage(
                        //                     'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611731.jpg',
                        //                   ),
                        //                 ),
                        //               ),
                        //               const SizedBox(width: 16),
                        //
                        //               // Text content
                        //               Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: const [
                        //                   Text(
                        //                     '5',
                        //                     style: TextStyle(
                        //                       fontSize: 24,
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: 4),
                        //                   Text(
                        //                     'Data',
                        //                     style: TextStyle(
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     Card(
                        //       elevation: 10,
                        //       shadowColor: Colors.blueAccent.withOpacity(0.3),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Container(
                        //         width: 165,
                        //         height: 110,
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(20),
                        //           gradient: LinearGradient(
                        //             colors: [Colors.white, Colors.white],
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //           ),
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(16.0),
                        //           child: Row(
                        //             crossAxisAlignment: CrossAxisAlignment.center,
                        //             children: [
                        //               // Avatar
                        //               CircleAvatar(
                        //                 radius: 28,
                        //                 backgroundColor: Colors.white,
                        //                 child: CircleAvatar(
                        //                   radius: 25,
                        //                   backgroundImage: NetworkImage(
                        //                     'https://img.freepik.com/free-psd/3d-render-avatar-character_23-2150611731.jpg',
                        //                   ),
                        //                 ),
                        //               ),
                        //               const SizedBox(width: 16),
                        //
                        //               // Text content
                        //               Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 crossAxisAlignment: CrossAxisAlignment.start,
                        //                 children: const [
                        //                   Text(
                        //                     '5',
                        //                     style: TextStyle(
                        //                       fontSize: 24,
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                   SizedBox(height: 4),
                        //                   Text(
                        //                     'Data',
                        //                     style: TextStyle(
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.black,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //
                        //   ],
                        // ),
                        // SizedBox(height: 20,),
                        // Card(
                        //   elevation: 10,
                        //   shadowColor: Colors.blueAccent.withOpacity(0.3),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: Container(
                        //     width: 500,
                        //     height: 110,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //     child: Text('data'),
                        //   )
                        // )
                        Text('Currently No data found...'),
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
