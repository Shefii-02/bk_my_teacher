import 'package:flutter/material.dart';

import '../webinars/webinar_listing.dart';

class FreeWebinarsScreen extends StatelessWidget {
  final String guestId;
  const FreeWebinarsScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context) {
    final webinars = [
      {"title": "Learn English Basics", "date": "Sep 28, 2025"},
      {"title": "Intro to Math Tricks", "date": "Oct 1, 2025"},
      {"title": "Science Made Fun", "date": "Oct 5, 2025"},
    ];

    // return Scaffold(
    //   appBar: AppBar(title: const Text("Free Webinars")),
    //   body: ListView.builder(
    //     itemCount: webinars.length,
    //     itemBuilder: (context, index) {
    //       final webinar = webinars[index];
    //       return Card(
    //         margin: const EdgeInsets.all(10),
    //         child: ListTile(
    //           title: Text(webinar["title"]!),
    //           subtitle: Text("Date: ${webinar["date"]}"),
    //           trailing: ElevatedButton(
    //             onPressed: () {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(content: Text("Joined ${webinar["title"]}!")),
    //               );
    //             },
    //             child: const Text("Join"),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
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
              // Top Section
              SizedBox(
                height: 110,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          // Container(
                          //   width: 40,
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     color: Colors.white.withOpacity(0.8),
                          //   ),
                          //   child: IconButton(
                          //     icon: const Icon(
                          //       Icons.keyboard_arrow_left_sharp,
                          //       color: Colors.black,
                          //     ),
                          //     iconSize: 20,
                          //     padding: EdgeInsets.zero,
                          //     onPressed: () {
                          //
                          //     },
                          //   ),
                          // ),

                          // Title
                          const Expanded(
                            child: Center(
                              child: Text(
                                "My Class List",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 40),
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
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Free Webinars",
                          style: TextStyle(fontSize: 16),
                        ),
                        WebinarListPage(),
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
