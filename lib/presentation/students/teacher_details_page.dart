import 'dart:io';

import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/endpoints.dart';
import '../widgets/show_success_alert.dart';


class TeacherDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> teacher;
  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  ConsumerState<TeacherDetailsPage> createState() => _TeacherDetailsPageState();
}

class _TeacherDetailsPageState extends ConsumerState<TeacherDetailsPage> {
  late Map<String, dynamic> teacherData;
  String selectedType = 'subject'; // subject or course
  List<String> selectedItems = [];
  String selectedClassType = 'individual'; // individual, common, crash
  final TextEditingController daysController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Dummy subjects & courses
  final List<String> subjects = ['Maths', 'Science', 'English', 'Computer'];
  final List<String> courses = ['NEET', 'JEE', 'Spoken English'];

  bool isSubmitting = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  Future<void> _shareTeacherProfile() async {
    try {
      // Capture screenshot
      final image = await _screenshotController.capture();

      if (image == null) return;

      // Save image temporarily
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/teacher_share.png';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(image);
      final referralCode = await LaunchStatusService.getReferralCode();

      String shortUrl = "${Endpoints.domain}/invite?ref=$referralCode";
      final message =
          "Join BookMyTeacher using my referral code $referralCode and earn rewards!\n$shortUrl";

      // Share using Share Plus
      await Share.shareXFiles(
        [XFile(filePath)],
        text:message,
      );
    } catch (e) {
      debugPrint("Error sharing teacher: $e");
    }
  }
  Future<void> submitClassDetails() async {
    setState(() => isSubmitting = true);

    try {
      final data = {
        'type': selectedType, // subject or course
        'selected_items': selectedItems,
        'class_type': selectedClassType,
        'days_needed': daysController.text,
        'notes': notesController.text,
      };

      final res = await ApiService().submitTeacherClassRequest(data);

      if (context.mounted) {
        Navigator.of(context).pop(); // closes the bottom sheet
      }

      showSuccessAlert(
        context,
        title: res?['status'] == true ? "Success!" : "failed",
        subtitle: res?['message'] ?? 'Class Booking details submitted successfully',
        timer: 6,
        color: res?['status'] == true ? Colors.green : Colors.red,
        showButton: false, // 👈 hide/show button easily
      );

      if (res?['status'] == true) {
        _resetForm();
        // ✅ Close the bottom sheet after success

      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacher = widget.teacher;
    final reviews = teacher['reviews'] ?? [];

    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // 🔹 Collapsible Header
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.green.shade600,
                  leading: _circleButton(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  actions: [
                    _circleButton(Icons.share_outlined, _shareTeacherProfile),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 🌈 Gradient background
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                AppConfig.bodyBg,
                              ), // Replace with your asset path
                              fit: BoxFit.cover,
                            ),
                            // gradient: LinearGradient(
                            //   colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            // ),
                          ),
                        ),
                        // 👩‍🏫 Profile Image
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Image.network(
                              teacher['imageUrl'] ??
                                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                              fit: BoxFit.cover,
                              height: 280,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 📄 Content
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            teacher['name'] ?? "Teacher Name",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              color: i < (teacher['rating'] ?? 4).round()
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 🧠 About Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "About Teacher",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 🔹 Description
                        if (teacher['description'] != null)
                          Text(
                            teacher['description'],
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        const SizedBox(height: 20),

                        // ✅ Info Rows
                        _detailRow("Ranking", "#${teacher['ranking'] ?? 1}"),
                        _detailRow("Qualification", teacher['qualification']),
                        _detailRow("Subjects", teacher['subjects']),
                        _detailRow(
                          "Student Rating",
                          "${(teacher['rating'] ?? 4.5).toStringAsFixed(1)} ⭐",
                        ),

                        const SizedBox(height: 25),
                        const Divider(),

                        // 💬 Reviews
                        if (reviews.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Student Reviews",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              CarouselSlider.builder(
                                itemCount: reviews.length,
                                options: CarouselOptions(
                                  height: 160,
                                  enlargeCenterPage: true,
                                  autoPlay: true,
                                  viewportFraction: 0.85,
                                ),
                                itemBuilder: (context, index, _) {
                                  final review = reviews[index];

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade300.withOpacity(0.2),
                                          Colors.white,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 🟢 Avatar Section
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.green.shade200,
                                          backgroundImage: (review['avatar'] != null &&
                                              review['avatar'].toString().isNotEmpty)
                                              ? NetworkImage(review['avatar'])
                                              : const AssetImage('assets/images/default_avatar.png')
                                          as ImageProvider,
                                        ),
                                        const SizedBox(width: 12),

                                        // 🟢 Review Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review['name'] ?? 'Student',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: List.generate(
                                                  5,
                                                      (i) => Icon(
                                                    Icons.star,
                                                    color:
                                                    i < (review['rating']?.round() ?? 4)
                                                        ? Colors.amber
                                                        : Colors.grey.shade300,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                review['comment'] ??
                                                    'Very knowledgeable and kind teacher.',
                                                style: const TextStyle(fontSize: 13),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🟢 Floating Book Button
            Positioned(
              bottom: 25,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: _showBookingSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "Book Demo / Class",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title:",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        Flexible(
          child: Text(
            value ?? "-",
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    ),
  );

  Widget _circleButton(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Icon(icon, color: Colors.black87),
    ),
  );

  // 🧩 Stylish Booking Bottom Sheet
  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 25,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "📘 Book a Class",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Subject"),
                      selectedColor: Colors.green.shade100,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      selected: selectedType == "subject",
                      onSelected: (_) =>
                          setModalState(() => selectedType = "subject"),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Course"),
                      selectedColor: Colors.green.shade100,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      selected: selectedType == "course",
                      onSelected: (_) =>
                          setModalState(() => selectedType = "course"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text(
                  selectedType == "subject"
                      ? "Select Subject(s)"
                      : "Select Course(s)",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children:
                      (selectedType == "subject"
                              ? ["Maths", "English", "Science", "Physics"]
                              : [
                                  "Crash Course",
                                  "Programming Basics",
                                  "AI Course",
                                ])
                          .map(
                            (item) => FilterChip(
                              label: Text(item),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              selected: selectedItems.contains(item),
                              selectedColor: Colors.green.shade200,
                              onSelected: (val) {
                                setModalState(() {
                                  if (val) {
                                    selectedItems.add(item);
                                  } else {
                                    selectedItems.remove(item);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Class Type",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Wrap(
                  spacing: 10,
                  children: ["Individual", "Common", "Crash"]
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type),
                          selected: selectedClassType == type,
                          selectedColor: Colors.green.shade200,
                          onSelected: (_) =>
                              setModalState(() => selectedClassType = type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Number of Days",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        9.0,
                      ), // Adjust the radius as needed
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Notes (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        9.0,
                      ), // Adjust the radius as needed
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text("Booking request submitted!"),
                //         backgroundColor: Colors.green,
                //       ),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.green.shade600,
                //     minimumSize: const Size(double.infinity, 55),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(15),
                //     ),
                //   ),
                //   child: const Text(
                //     "Submit Booking",
                //     style: TextStyle(color: Colors.white, fontSize: 16),
                //   ),
                // ),
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : submitClassDetails,
                  icon: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Icon(Icons.send,color: Colors.white,),
                  label: Text(isSubmitting ? 'Submitting...' : 'Submit Booking',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      daysController.clear();
      notesController.clear();
      selectedItems.clear();
      selectedType = 'subject';
      selectedClassType = 'individual';
    });
  }
}
