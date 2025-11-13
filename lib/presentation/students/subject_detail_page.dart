import 'dart:io';

import 'package:BookMyTeacher/presentation/students/teacher_details_page.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/endpoints.dart';
import '../../core/enums/app_config.dart';
import '../../services/launch_status_service.dart';
import '../widgets/show_success_alert.dart';
import '../widgets/teacher_profile_card.dart';

class SubjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectDetailPage({super.key, required this.subject});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  bool isSubmitting = false;
  late final subjectData = widget.subject;
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareTeacherProfile() async {
    try {
      // Capture screenshot
      final image = await _screenshotController.capture();

      if (image == null) return;

      // Save image temporarily
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/subject_share.png';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(image);
      final referralCode = await LaunchStatusService.getReferralCode();

      String shortUrl = "${Endpoints.domain}/invite?ref=$referralCode";
      final message =
          "Join BookMyTeacher using my referral code $referralCode and earn rewards!\n$shortUrl";

      // Share using Share Plus
      await Share.shareXFiles([XFile(filePath)], text: message);
    } catch (e) {
      debugPrint("Error sharing teacher: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List teachers = subjectData['available_teachers'] ?? [];
    final List reviews = subjectData['reviews'] ?? [];
    print(subjectData);
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
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(bottom: 20),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subjectData['name'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),

                        // if (subjectData['trending'] != null)
                          Text("Trending : #${subjectData['trending'] ?? '1'}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 🌄 Background Image
                        if (subjectData['main_image'] != null)
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(subjectData['main_image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // 🌫 Gradient Overlay for Text Visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.4),
                                Colors.black.withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
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
                        const SizedBox(height: 20),
                        // 🔹 Description
                        if (subjectData['description'] != null)
                          Text(
                            subjectData['description'],
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),

                        const SizedBox(height: 25),
                        // 👩‍🏫 Available Teachers
                        const Text(
                          "Available Teachers",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = teachers[index];
                            return TeacherProfileCard(
                              name: teacher['name'].length > 13
                                  ? "${teacher['name'].substring(0, 13)}.."
                                  : teacher['name'],
                              qualification: teacher['qualification'],
                              subjects: teacher['subjects'],
                              ranking: teacher['ranking'],
                              rating: teacher['rating'].toDouble(),
                              imageUrl: teacher['imageUrl'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TeacherDetailsPage(teacher: teacher),
                                  ),
                                );
                              },
                            );

                          },
                        ),


                        const Divider(),
                        const SizedBox(height: 25),
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
                              const SizedBox(height: 20),
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
                                          Colors.green.shade500,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 🟢 Avatar Section
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor:
                                              Colors.green.shade200,
                                          backgroundImage:
                                              (review['avatar'] != null &&
                                                  review['avatar']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? NetworkImage(review['avatar'])
                                              : const AssetImage(
                                                      'assets/images/default_avatar.png',
                                                    )
                                                    as ImageProvider,
                                        ),
                                        const SizedBox(width: 12),

                                        // 🟢 Review Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                        i <
                                                            (review['rating']
                                                                    ?.round() ??
                                                                4)
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
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
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
              bottom: 45,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () => _openBookingForm(context),
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

  // 🧩 Teacher Card Widget
  // Widget _buildTeacherCard(Map teacher) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     elevation: 3,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         const SizedBox(height: 8),
  //         CircleAvatar(
  //           backgroundImage: NetworkImage(teacher['imageUrl'] ?? ''),
  //           radius: 35,
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           teacher['name'] ?? '',
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //         ),
  //         Text(
  //           teacher['qualification'] ?? '',
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(fontSize: 12, color: Colors.grey),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           "${teacher['experience'] ?? ''} Exp",
  //           style: const TextStyle(fontSize: 12, color: Colors.black54),
  //         ),
  //         const SizedBox(height: 4),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: List.generate(
  //             5,
  //             (i) => Icon(
  //               i < (teacher['ranking'] ?? 0) ? Icons.star : Icons.star_border,
  //               color: Colors.amber,
  //               size: 16,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 🧩 Review Card Widget
  Widget _buildReviewCard(Map review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(review['avatar'] ?? ''),
          radius: 25,
        ),
        title: Text(
          review['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(review['comment'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (i) => Icon(
              i < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _openBookingForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BookClassForm(subject: widget.subject),
    );
  }

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

  // Widget _detailRow(String title, String? value) => Padding(
  //   padding: const EdgeInsets.symmetric(vertical: 6),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         "$title:",
  //         style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
  //       ),
  //       Flexible(
  //         child: Text(
  //           value ?? "-",
  //           textAlign: TextAlign.right,
  //           style: const TextStyle(fontSize: 14, color: Colors.black87),
  //         ),
  //       ),
  //     ],
  //   ),
  // );
}
class BookClassForm extends StatefulWidget {
  final Map<String, dynamic> subject; // expects subject data including teachers

  const BookClassForm({super.key, required this.subject});

  @override
  State<BookClassForm> createState() => _BookClassFormState();
}

class _BookClassFormState extends State<BookClassForm> {
  final _formKey = GlobalKey<FormState>();

  final _days = TextEditingController();
  final _note = TextEditingController();

  int? _selectedTeacherId;
  bool _loading = false;

  @override
  void dispose() {
    _days.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachers = widget.subject['available_teachers'] ?? [];

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Book ${widget.subject['name']} Class",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// TEACHER SELECTION
              if (teachers.isNotEmpty) ...[
                const Text(
                  "Choose a Teacher",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return RadioListTile<int>(
                      value: teacher['id'],
                      groupValue: _selectedTeacherId,
                      onChanged: (value) =>
                          setState(() => _selectedTeacherId = value),
                      title: Text(teacher['name']),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                const Text("No teachers available for this subject."),
                const SizedBox(height: 16),
              ],

              /// FORM FIELDS
              _buildTextField(_days, "How many days you want"),
              _buildTextField(_note, "Message / Notes", maxLines: 3),
              const SizedBox(height: 20),

              /// SUBMIT BUTTON
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _submitBooking,
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white),
                label: const Text(
                  "Submit Booking",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Text Field Builder
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType? keyboard,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          return null;
        },
      ),
    );
  }

  /// API CALL: Submit Booking
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a teacher."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final data = {
        "subject_id": widget.subject['id'],
        "teacher_id": _selectedTeacherId,
        "days": _days.text.trim(),
        "note": _note.text.trim(),
      };

      final res = await ApiService().requestSubjectClassBooking(data);

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
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }


  void _resetForm() {
    setState(() {
      _days.clear();
      _note.clear();
    });
  }
}