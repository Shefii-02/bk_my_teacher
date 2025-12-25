import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../widgets/show_failed_alert.dart';
import '../widgets/show_success_alert.dart';



class CourseDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> course;
  final redirectTo;
  const CourseDetailBottomSheet({super.key, required this.course, required  this.redirectTo});

  @override
  State<CourseDetailBottomSheet> createState() =>
      CourseDetailBottomSheetState();
}

class CourseDetailBottomSheetState extends State<CourseDetailBottomSheet> {
  bool _submitting = false;
  bool _enrolled = false;
  String get redirectTo => widget.redirectTo;


  Future<void> _enrollCourse() async {
    setState(() => _submitting = true);
    try {
      final response = await ApiService().requestCourseEnrollment(
        widget.course['id'].toString(),
      );

      if (response?['status'] == true) {
        setState(() => _enrolled = true);

        showSuccessAlert(context, title: 'Success', subtitle: response?['message'], timer: 3, color: Colors.green,showButton:false);
        // context.go(redirectTo);
        Future.delayed(const Duration(seconds: 2), () {
          // Redirect to landing page
          context.go(redirectTo);
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(response?['message'] ?? 'Enrolled!')),
        // );
      }
      else{
        showFailedAlert(context, title: 'Failed', subtitle: response?['message'], timer: 3, color: Colors.red,showButton:false);
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _redirectToEnrolledCourse() {
    Navigator.of(context).pop(); // close bottom sheet
    context.push('/class-detail', extra: widget.course['id'].toString());
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    _enrolled = _enrolled || (course['is_enrolled'] ?? false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // ===================== CONTENT =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dragHandle(),

                  // 🔥 HERO IMAGE
                  if ((course['main_image_url'] ?? '').isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        course['main_image_url'],
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 🔥 TITLE
                  Text(
                    course['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 DESCRIPTION
                  Text(
                    course['description'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // 🔥 INFO ROWS
                  _infoRow(
                    Icons.schedule,
                    "Starts",
                    _formatDate(course['started_at']),
                  ),
                  _infoRow(
                    Icons.event,
                    "Ends",
                    _formatDate(course['ended_at']),
                  ),
                  _infoRow(
                    Icons.person,
                    "Instructor",
                    course['host']?['name'] ?? 'TBA',
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // ===================== STICKY PURCHASE BAR =====================
          Positioned(bottom: 0, left: 0, right: 0, child: _purchaseBar(course)),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  Widget _purchaseBar(Map<String, dynamic> course) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: GestureDetector(
        // onTap: _submitting || _enrolled ? null : _enrollCourse,
        onTap: _submitting
            ? null
            : () {
          if (_enrolled) {
            _redirectToEnrolledCourse();
          } else {
            _enrollCourse();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: _enrolled
                ? null
                : const LinearGradient(
              colors: [Color(0xff16a34a), Color(0xff22c55e)],
            ),
            color: _enrolled ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _submitting
              ? const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
              : AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _enrolled
                ? Row(
              key: const ValueKey("enrolled"),
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_rounded, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Enrolled",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            )
                : Row(
              key: const ValueKey("buy"),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                priceView(
                  actualPrice: course['actual_price'],
                  netPrice: course['net_price'],
                ),
                const Text(
                  "Enroll Now",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 50,
        height: 5,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return 'TBA';
    return DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(date));
  }
}

Widget priceView({required dynamic actualPrice, required dynamic netPrice}) {
  if (netPrice == null) return const SizedBox.shrink();

  final actual = double.tryParse(actualPrice.toString());
  final net = double.tryParse(netPrice.toString());

  if (actual == null || net == null) {
    return const SizedBox.shrink();
  }

  // 🎯 If discounted
  if (actual > net) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(
            "₹${actual.toStringAsFixed(0)}",
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.red,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "₹${net.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 No discount
  return Text(
    "₹${net.toStringAsFixed(0)}",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      color: Colors.white,
    ),
  );
}
