import 'dart:ui';
import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/presentation/students/teacher_details_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherSearchResultPage extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Map<String, dynamic> result;

  const TeacherSearchResultPage({
    super.key,
    required this.filters,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    // final multiTeachers = result["multi_subject_teachers"] ?? [];
    // final subjectWise = result["single_subject_teachers"] ?? {};

    // final multiTeachers =
    // (result["multi_subject_teachers"] ?? []) as List;
    //
    // final subjectWise =
    // (result["single_subject_teachers"] ?? {}) as Map<String, dynamic>;
    //
    // final recommendedTeachers =
    // (result["recommended_teachers"] ?? []) as List;

    final multiTeachers = safeList(result["multi_subject_teachers"]);
    final subjectWise = safeMap(result["single_subject_teachers"]);
    final recommendedTeachers = safeList(result["recommended_teachers"]);

    // final hasTeachers =
    //     multiTeachers.isNotEmpty || subjectWise.values.any((e) => e.isNotEmpty);

    final hasMulti = multiTeachers.isNotEmpty;

    final hasSubjectWise =
    subjectWise.values.any((e) => (e as List).isNotEmpty);

    final hasRecommended = recommendedTeachers.isNotEmpty;

    final hasTeachers = hasMulti || hasSubjectWise || hasRecommended;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a your teacher"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔹 Selected Filters
          _FiltersCard(filters: filters),

          const SizedBox(height: 16),

          if (hasTeachers) ...[
            /// 🔥 Multi Subject Teachers
            if (multiTeachers.isNotEmpty) ...[
              const Text(
                "Best Matches",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...multiTeachers.map<Widget>((t) => TeacherCard(data: t)),

              const SizedBox(height: 20),
            ],

            /// 🔥 Subject Wise Sections
            ...subjectWise.entries.map<Widget>((entry) {
              final subject = entry.key;
              final teachers = entry.value as List;

              if (teachers.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$subject Teachers",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...teachers.map<Widget>((t) => TeacherCard(data: t)),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),

            /// ⭐ Recommended Teachers
            if (hasRecommended) ...[
              const Text(
                "Recommended for You",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...recommendedTeachers.map<Widget>((t) => TeacherCard(data: t)),
              const SizedBox(height: 20),
            ],

          ] else ...[
          /// ❌ No Teachers → Blur Private Profiles
          _PrivateProfilesSection(filters: filters),
          ],
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final Map<String, dynamic> filters;

  const _FiltersCard({required this.filters});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row("Grade", filters["grade"]),
            _row("Board", filters["board"]),
            _row("Subjects", filters["subjects"].join(", ")),
            _row("Mode", filters["modes"].join(", ")),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text("$label: $value"),
    );
  }
}

class TeacherCard extends StatelessWidget {
  // final Map data;
  final Map<String, dynamic> data;


  const TeacherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return TeacherProfileCard(
      name: data["name"].length > 13
          ? "${data["name"].substring(0, 13)}.."
          : data["name"],
      qualification: data["qualification"].length > 13
          ? "${data["qualification"].substring(0, 13)}.."
          : data["qualification"],
      subjects: data["subjects"].length > 13
          ? "${data["subjects"].substring(0, 13)}.."
          : data["subjects"],
      ranking: data["ranking"],
      rating: data['rating'].toDouble(),
      imageUrl: data['imageUrl'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherDetailsPage(teacher: data),
          ),
        );
      },
    );
    //   TeacherProfileCard(
    //   name: data["name"],
    //   qualification: data["qualification"],
    //   subjects: data["subjects"],
    //   ranking: data["ranking"],
    //   rating: data["rating"],
    //   imageUrl: data["imageUrl"],
    // );
    //   Card(
    //   margin: const EdgeInsets.only(bottom: 12),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   child: ListTile(
    //     leading: CircleAvatar(
    //       backgroundImage: NetworkImage(data["avatar"] ?? ""),
    //     ),
    //     title: Text(data["name"] ?? "Teacher"),
    //     subtitle: Text(data["subjects"]?.join(", ") ?? ""),
    //     trailing: ElevatedButton(
    //       onPressed: () {},
    //       child: const Text("View"),
    //     ),
    //   ),
    // );
  }
}

class TeacherProfileCard extends StatelessWidget {
  final String name;
  final String qualification;
  final String subjects;
  final int ranking;
  final double rating;
  final String imageUrl;
  final VoidCallback? onTap; // ✅ add this

  const TeacherProfileCard({
    super.key,
    required this.name,
    required this.qualification,
    required this.subjects,
    required this.ranking,
    required this.rating,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ✅ make entire card tappable
      onTap: onTap,
      child: SizedBox(
        height: 150,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 25,
              left: 0,
              right: 0,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 30,
              child: Text(
                name.length > 13 ? "${name.substring(0, 13)}.." : name,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 60,
              child: Text(
                qualification,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF3AB769),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 80,
              child: Text(
                subjects,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 100,
              child: Text(
                "Rank: $ranking",
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFFEABD6C),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 120,
              child: Row(
                children: [
                  const Text(
                    "Student Rating:",
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF979797),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivateProfilesSection extends StatelessWidget {
  final Map<String, dynamic> filters;

  const _PrivateProfilesSection({required this.filters});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Premium Teachers",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        const Text(
          "These teachers are private profiles.\nConnect with us — our team will assist you.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: () => _connectOnWhatsApp(context, filters),
          child: const Text("Connect Now"),
        ),
        const SizedBox(height: 12),

        /// 🔥 Blur Cards
        ...List.generate(6, (index) => _BlurTeacherCard()),

        const SizedBox(height: 20),

      ],
    );
  }
}

List safeList(dynamic v) => v is List ? v : [];
Map<String, dynamic> safeMap(dynamic v) =>
    v is Map<String, dynamic> ? v : {};

class _BlurTeacherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TeacherCard(
          data: {
            "name": "Anu Thomas",
            "qualification": "MSc Maths",
            "subjects": "Maths, Algebra",
            "ranking": 1,
            "rating": 4.5,
            "imageUrl": "${Endpoints.domain}/dummy-avatar.png",
          },
        ),
        SizedBox(height: 180),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _connectOnWhatsApp(
  BuildContext context,
  Map<String, dynamic> filters,
) async {
  final message =
      """
Hello BookMyTeacher Team 👋

I'm looking for a teacher.

Grade: ${filters["grade"]}
Board: ${filters["board"]}
Subjects: ${filters["subjects"].join(", ")}
Mode: ${filters["modes"].join(", ")}

Please assist me.
""";

  final encoded = Uri.encodeComponent(message);

  final url = Uri.parse("https://wa.me/917510115544?text=$encoded");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("WhatsApp not installed")));
  }
}
