import 'package:BookMyTeacher/model/course_details_model.dart';
import 'package:flutter/material.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CourseReview extends StatefulWidget {
  final CourseInfo course;

  const CourseReview(this.course, {super.key});

  @override
  State<CourseReview> createState() => _CourseReviewState();
}

class _CourseReviewState extends State<CourseReview> {
  CourseReviewModel? existingReview;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReview();
  }

  Future<void> loadReview() async {
    final course  = widget.course;
    final data = await ApiService().fetchMyCourseReview(course.id);

    setState(() {
      existingReview = data as CourseReviewModel;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 140,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow color with opacity
              offset: const Offset(0, 0), // Shadow offset (right and down)
              blurRadius: 2.0, // Softness of the shadow
              spreadRadius: 0.1, // Expansion of the shadow
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),

        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      existingReview != null
                          ? 'Edit Your Review'
                          : 'Share Your Experience',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      existingReview != null
                          ? 'You already submitted a review'
                          : 'Give our app a smile by sharing your experience',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        fixedSize: const Size(65, 25),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFF1A1A22),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) =>
                              ReviewBottomSheet(existingReview: existingReview,course : widget.course),
                        );

                        /// REFRESH AFTER SUBMIT
                        loadReview();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 2,),
                          Text(
                            existingReview != null ? 'Edit Now' : 'Write Now',
                            style: TextStyle(color: Colors.white,fontSize: 8),
                          ),
                        ],
                      )

                    ),
                  ],
                ),
              ),
            ),

            // IMAGE
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset(
                'assets/images/icons/app-review.png',
                width: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseReviewModel {
  String rating;
  String feedback;

  CourseReviewModel({
    required this.rating,
    required this.feedback,
  });

  factory CourseReviewModel.fromJson(Map<String, dynamic> json) {
    return CourseReviewModel(
      rating: json['rating'] ?? 0,
      feedback: json['feedback'] ?? "",
    );
  }
}

class ReviewBottomSheet extends StatefulWidget {
  final CourseReviewModel? existingReview;
  final CourseInfo course;

  const ReviewBottomSheet({super.key, this.existingReview, required this.course});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  String selectedRating = '';
  bool isSubmitting = false;

  final TextEditingController controller = TextEditingController();

  final List<String> labels = [
    "Happy",
    "Good",
    "Average",
    "Below Average",
    "Very Bad",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingReview != null) {
      selectedRating = widget.existingReview!.rating;
      controller.text = widget.existingReview!.feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Feedback Now",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),

              const SizedBox(height: 10),

              const Text(
                "We’d love to hear your thoughts. Your feedback helps us improve!",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              /// RATING OPTIONS
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(5, (index) {
                  return ChoiceChip(
                    label: Text(labels[index]),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.green,
                    selected: selectedRating == labels[index],
                    selectedColor: Colors.green,
                    onSelected: (_) {
                      setState(() {
                        selectedRating = labels[index];
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              /// TEXT FIELD
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Say something about us...",
                  hintStyle: TextStyle(color: Colors.black26),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => submitReview(widget.course.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitReview(int id) async {

    if (selectedRating.isEmpty) {
      showMessage("Select rating", "failed");
      return;
    }

    setState(() => isSubmitting = true);

    final res = await ApiService().submitCourseReview(
      rating: selectedRating,
      message: controller.text,
      courseId: id,
    );

    setState(() => isSubmitting = false);

    if (res != null && res['status'] == true) {
      Navigator.pop(context);
      showMessage("Review submitted", "success");
    } else {
      showMessage("Failed", "failed");
    }
  }

  void showMessage(String msg,String result) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: result == 'success' ? Colors.green : Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(msg, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
