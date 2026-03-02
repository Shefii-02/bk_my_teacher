import 'dart:ui';
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
    final multiTeachers = result["multi_subject_teachers"] ?? [];
    final subjectWise = result["single_subject_teachers"] ?? {};

    final hasTeachers =
        multiTeachers.isNotEmpty || subjectWise.values.any((e) => e.isNotEmpty);

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
  final Map data;

  const TeacherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(data["avatar"] ?? ""),
        ),
        title: Text(data["name"] ?? "Teacher"),
        subtitle: Text(data["subjects"]?.join(", ") ?? ""),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text("View"),
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

        /// 🔥 Blur Cards
        ...List.generate(6, (index) => _BlurTeacherCard()),

        const SizedBox(height: 20),

        const Text(
          "These teachers are private profiles.\nConnect with us — our team will assist you.",
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          onPressed: () => _connectOnWhatsApp(context, filters),
          child: const Text("Connect Now"),
        ),
      ],
    );
  }
}

class _BlurTeacherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const TeacherCard(data: {}),

        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


Future<void> _connectOnWhatsApp(
    BuildContext context, Map<String, dynamic> filters) async {
  final message = """
Hello BookMyTeacher Team 👋

I'm looking for a teacher.

Grade: ${filters["grade"]}
Board: ${filters["board"]}
Subjects: ${filters["subjects"].join(", ")}
Mode: ${filters["modes"].join(", ")}

Please assist me.
""";

  final encoded = Uri.encodeComponent(message);

  final url = Uri.parse("https://wa.me/91XXXXXXXXXX?text=$encoded");

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("WhatsApp not installed")),
    );
  }
}